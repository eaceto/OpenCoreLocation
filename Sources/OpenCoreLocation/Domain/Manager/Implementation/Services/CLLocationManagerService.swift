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
                delegate?.locationManagerService(self, didUpdateLocation: location)
            } catch {
                // If high-accuracy provider fails, try fallback
                if provider.id == "gpsd", let fallbackProvider = providers[kCLLocationAccuracyHundredMeters] {
                    do {
                        let location = try await fallbackProvider.requestLocation()
                        delegate?.locationManagerService(self, didUpdateLocation: location)
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
    }
}

// MARK: - CLLocationManagerServiceDelegate
internal protocol CLLocationManagerServiceDelegate: AnyObject {
    func locationManagerService(_ service: CLLocationManagerService, didUpdateLocation location: SendableCLLocation)
    func locationManagerService(_ service: CLLocationManagerService, didFailWithError error: Error)
}
