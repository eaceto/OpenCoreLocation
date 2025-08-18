import Foundation

#if canImport(CoreFoundation)
import CoreFoundation
#endif

// MARK: - CLLocationManagerService
/// Handles the business logic for CLLocationManager including accuracy-based provider selection and reactive location updates.
final class CLLocationManagerService {
    // MARK: - Errors
    enum Errors: Error {
        case noProviderForAccuracy
        case failedToUpdateLocation
    }

    // MARK: - Properties
    /// Mapping of accuracy types to location providers
    private var providers: [CLLocationAccuracy: any LocationProviderContract]
    private var currentProvider: (any LocationProviderContract)?

    /// Delegate to notify about location updates and errors
    weak var delegate: CLLocationManagerServiceDelegate?

    /// Timer for continuous location updates
    private var locationUpdateTimer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.opencorelocation.CLLocationManagerService.queue", attributes: .concurrent)
    
    /// Distance filter configuration and tracking
    private var distanceFilter: CLLocationDistance = kCLDistanceFilterNone
    private var lastReportedLocation: SendableCLLocation?
    private let locationTrackingQueue = DispatchQueue(label: "com.opencorelocation.CLLocationManagerService.tracking", attributes: .concurrent)

    // MARK: - Initializer
    init() {
        // Initialize providers based on accuracy requirements
        // Higher accuracy uses GPS, medium uses WiFi, low uses IP
        let gpsProvider = GPSLocationProvider()
        let wifiProvider = WiFiLocationProvider()
        let ipProvider = LowAccuracyLocationProvider()
        
        self.providers = [
            kCLLocationAccuracyBestForNavigation: gpsProvider,
            kCLLocationAccuracyBest: gpsProvider,
            kCLLocationAccuracyNearestTenMeters: gpsProvider,
            kCLLocationAccuracyHundredMeters: wifiProvider,
            kCLLocationAccuracyKilometer: ipProvider,
            kCLLocationAccuracyThreeKilometers: ipProvider
        ]
    }

    // MARK: - Setup Methods
    /// Assigns a custom provider for a specific accuracy
    func setProvider(for accuracy: CLLocationAccuracy, provider: any LocationProviderContract) {
        providers[accuracy] = provider
    }
    
    /// Sets the distance filter for location updates
    /// - Parameter distance: The minimum distance in meters that the device must move before generating an update event
    func setDistanceFilter(_ distance: CLLocationDistance) {
        locationTrackingQueue.async(flags: .barrier) {
            self.distanceFilter = distance
        }
    }
    
    /// Resets the distance filter tracking by clearing the last reported location
    func resetDistanceFilter() {
        locationTrackingQueue.async(flags: .barrier) {
            self.lastReportedLocation = nil
        }
    }
    
    /// Selects the best available provider based on desired accuracy
    /// Falls back to lower accuracy providers if higher ones are unavailable
    private func selectProvider(for accuracy: CLLocationAccuracy) -> (any LocationProviderContract)? {
        // Try to get the exact provider for requested accuracy
        if let provider = providers[accuracy] {
            return provider
        }
        
        // Define accuracy hierarchy for fallback
        let accuracyHierarchy: [CLLocationAccuracy] = [
            kCLLocationAccuracyBestForNavigation,
            kCLLocationAccuracyBest,
            kCLLocationAccuracyNearestTenMeters,
            kCLLocationAccuracyHundredMeters,
            kCLLocationAccuracyKilometer,
            kCLLocationAccuracyThreeKilometers
        ]
        
        // Find the closest available accuracy
        let requestedIndex = accuracyHierarchy.firstIndex { $0 == accuracy } ?? accuracyHierarchy.count
        
        // Try providers from requested accuracy downward (less accurate)
        for i in requestedIndex..<accuracyHierarchy.count {
            if let provider = providers[accuracyHierarchy[i]] {
                return provider
            }
        }
        
        // If no less accurate provider found, try more accurate ones
        for i in (0..<requestedIndex).reversed() {
            if let provider = providers[accuracyHierarchy[i]] {
                return provider
            }
        }
        
        // Last resort: return any available provider
        return providers.values.first
    }
    
    /// Determines if a location update should be reported based on the distance filter
    /// - Parameter newLocation: The new location to check
    /// - Returns: True if the location should be reported, false if it should be filtered out
    private func shouldReportLocation(_ newLocation: SendableCLLocation) -> Bool {
        return locationTrackingQueue.sync {
            // If distance filter is disabled, always report
            guard distanceFilter > 0 else { return true }
            
            // If no previous location, always report the first location
            guard let lastLocation = lastReportedLocation else { return true }
            
            // Calculate distance between current and last reported location
            let distance = calculateDistance(
                from: (latitude: lastLocation.latitude, longitude: lastLocation.longitude),
                to: (latitude: newLocation.latitude, longitude: newLocation.longitude)
            )
            
            // Report if distance exceeds filter threshold
            return distance >= distanceFilter
        }
    }
    
    /// Updates the last reported location for distance filter tracking
    /// - Parameter location: The location that was just reported
    private func updateLastReportedLocation(_ location: SendableCLLocation) {
        locationTrackingQueue.async(flags: .barrier) {
            self.lastReportedLocation = location
        }
    }
    
    /// Calculates the great-circle distance between two coordinate points using the haversine formula
    /// - Parameters:
    ///   - from: Starting coordinate (latitude, longitude)
    ///   - to: Ending coordinate (latitude, longitude)
    /// - Returns: Distance in meters
    private func calculateDistance(from: (latitude: Double, longitude: Double), to: (latitude: Double, longitude: Double)) -> CLLocationDistance {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180
        
        let dLat = lat2 - lat1
        let dLon = lon2 - lon1
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let R: CLLocationDistance = 6371000 // Earth radius in meters
        
        return R * c
    }

    // MARK: - One-Time Location Request
    /// Requests the user's location **once** (single update)
    /// - Apple Docs: ["Requests the one-time delivery of the user's current location."](https://developer.apple.com/documentation/corelocation/cllocationmanager/requestlocation)
    func requestLocation(with accuracy: CLLocationAccuracy) async {
        do {
            guard let provider = selectProvider(for: accuracy) else {
                delegate?.locationManagerService(self, didFailWithError: Errors.noProviderForAccuracy)
                return
            }
            let currentProviderId = currentProvider?.id

            if currentProviderId != provider.id {
                try await currentProvider?.stop()
                try await provider.start()
                currentProvider = provider
            }

            // Try primary provider first
            do {
                let location = try await provider.requestLocation()
                
                // Apply distance filter before reporting location
                if shouldReportLocation(location) {
                    updateLastReportedLocation(location)
                    delegate?.locationManagerService(self, didUpdateLocation: location)
                }
                // Note: Even if filtered, this is considered a successful location request
            } catch {
                // If high-accuracy provider fails, try fallback
                if provider.id == "gpsd", let fallbackProvider = providers[kCLLocationAccuracyHundredMeters] {
                    do {
                        let location = try await fallbackProvider.requestLocation()
                        
                        // Apply distance filter to fallback location too
                        if shouldReportLocation(location) {
                            updateLastReportedLocation(location)
                            delegate?.locationManagerService(self, didUpdateLocation: location)
                        }
                        return
                    } catch {
                        // Fallback also failed
                    }
                }
                throw error
            }
        } catch {
            delegate?.locationManagerService(self, didFailWithError: error)
        }
    }

    // MARK: - Continuous Location Updates
    func startUpdatingLocation(with accuracy: CLLocationAccuracy) {
        stopUpdatingLocation() // Ensure we clear any previous update cycles

        // Select best available provider for the accuracy level
        guard let provider = selectProvider(for: accuracy) else {
            delegate?.locationManagerService(self, didFailWithError: Errors.noProviderForAccuracy)
            return
        }

        let interval = provider.poolInterval

        // Start the timer with the provider's pool interval
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: interval)

        timer.setEventHandler { [weak self] in
            Task {
                await self?.requestLocation(with: accuracy)
            }
        }

        locationUpdateTimer = timer // Store the timer reference
        timer.resume() // Start the timer
    }

    func stopUpdatingLocation() {
        locationUpdateTimer?.cancel()
        locationUpdateTimer = nil
        
        // Reset distance filter tracking when stopping location updates
        resetDistanceFilter()
    }
}

// MARK: - CLLocationManagerServiceDelegate
internal protocol CLLocationManagerServiceDelegate: AnyObject {
    func locationManagerService(_ service: CLLocationManagerService, didUpdateLocation location: SendableCLLocation)
    func locationManagerService(_ service: CLLocationManagerService, didFailWithError error: Error)
}
