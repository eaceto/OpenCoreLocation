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
    
    /// Region monitoring
    private var monitoredRegions: Set<CLRegion> = []
    private var regionStates: [String: CLRegionState] = [:]
    private let regionMonitoringQueue = DispatchQueue(label: "com.opencorelocation.CLLocationManagerService.regions", attributes: .concurrent)
    
    /// Background location updates configuration
    private var allowsBackgroundLocationUpdates: Bool = false
    private var pausesLocationUpdatesAutomatically: Bool = false
    
    /// Stationary detection for automatic pausing
    private var stationaryLocation: SendableCLLocation?
    private var stationaryStartTime: Date?
    private let stationaryThreshold: CLLocationDistance = 10.0 // meters
    private let stationaryTimeout: TimeInterval = 60.0 // seconds
    private var isPaused: Bool = false
    
    /// Adaptive interval management
    private var currentUpdateInterval: TimeInterval = 1.0
    private let foregroundInterval: TimeInterval = 1.0
    private let backgroundInterval: TimeInterval = 30.0
    private let stationaryInterval: TimeInterval = 60.0

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
    
    /// Configures background location updates
    /// - Parameter allowed: Whether background location updates are allowed
    func setAllowsBackgroundLocationUpdates(_ allowed: Bool) {
        queue.async(flags: .barrier) {
            self.allowsBackgroundLocationUpdates = allowed
            // Adjust update interval based on background mode
            self.adjustUpdateInterval()
        }
    }
    
    /// Configures automatic pausing of location updates
    /// - Parameter pauses: Whether location updates should pause automatically when stationary
    func setPausesLocationUpdatesAutomatically(_ pauses: Bool) {
        queue.async(flags: .barrier) {
            self.pausesLocationUpdatesAutomatically = pauses
            if !pauses {
                // Reset paused state if automatic pausing is disabled
                self.isPaused = false
                self.stationaryLocation = nil
                self.stationaryStartTime = nil
            }
        }
    }
    
    /// Selects the best available provider based on desired accuracy
    /// Falls back to lower accuracy providers if higher ones are unavailable
    private func selectProvider(for accuracy: CLLocationAccuracy) -> (any LocationProviderContract)? {
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
    
    /// Tries multiple providers in order of preference for the given accuracy
    /// Returns the first provider that successfully provides a location
    private func requestLocationWithFallback(for accuracy: CLLocationAccuracy) async throws -> SendableCLLocation {
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
        var lastError: Error?
        var providersTried = 0
        
        for i in requestedIndex..<accuracyHierarchy.count {
            if let provider = providers[accuracyHierarchy[i]] {
                providersTried += 1
                
                do {
                    // Start provider if needed (start() methods don't usually fail)
                    if currentProvider?.id != provider.id {
                        try await currentProvider?.stop()
                        try await provider.start()
                        currentProvider = provider
                    }
                    
                    // The key fallback point - requestLocation() can fail
                    let location = try await provider.requestLocation()
                    return location
                } catch {
                    lastError = error
                    // Continue to next provider in hierarchy
                    continue
                }
            }
        }
        
        // If no provider worked, provide meaningful error
        if providersTried == 0 {
            throw Errors.noProviderForAccuracy
        } else {
            throw lastError ?? Errors.failedToUpdateLocation
        }
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
            let distance = CLLocationUtils.calculateDistance(
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
    
    /// Checks if the device is stationary and handles automatic pausing
    /// - Parameter location: The new location to check
    private func checkStationaryStatus(_ location: SendableCLLocation) {
        guard pausesLocationUpdatesAutomatically else { return }
        
        queue.async(flags: .barrier) {
            if let stationaryLoc = self.stationaryLocation {
                // Calculate distance from stationary point
                let distance = CLLocationUtils.calculateDistance(
                    from: (latitude: stationaryLoc.latitude, longitude: stationaryLoc.longitude),
                    to: (latitude: location.latitude, longitude: location.longitude)
                )
                
                if distance <= self.stationaryThreshold {
                    // Still stationary
                    if let startTime = self.stationaryStartTime {
                        let stationaryDuration = Date().timeIntervalSince(startTime)
                        
                        // Pause updates if stationary for too long
                        if stationaryDuration >= self.stationaryTimeout && !self.isPaused {
                            self.isPaused = true
                            self.adjustUpdateInterval()
                            print("[CLLocationManagerService] Pausing location updates - device stationary for \(Int(stationaryDuration))s")
                        }
                    }
                } else {
                    // Device has moved
                    if self.isPaused {
                        print("[CLLocationManagerService] Resuming location updates - device moved \(Int(distance))m")
                    }
                    self.isPaused = false
                    self.stationaryLocation = location
                    self.stationaryStartTime = Date()
                    self.adjustUpdateInterval()
                }
            } else {
                // First location, start tracking
                self.stationaryLocation = location
                self.stationaryStartTime = Date()
                self.isPaused = false
            }
        }
    }
    
    /// Adjusts the update interval based on current conditions
    private func adjustUpdateInterval() {
        var newInterval: TimeInterval
        
        if isPaused {
            // Device is stationary, use longest interval
            newInterval = stationaryInterval
        } else if allowsBackgroundLocationUpdates {
            // Background mode, use longer interval
            newInterval = backgroundInterval
        } else {
            // Foreground mode, use normal interval
            newInterval = foregroundInterval
        }
        
        // Only restart timer if interval has changed
        if newInterval != currentUpdateInterval {
            currentUpdateInterval = newInterval
            
            // Restart the timer with new interval if it's running
            if locationUpdateTimer != nil {
                let accuracy = currentProvider?.poolInterval ?? kCLLocationAccuracyBest
                restartLocationUpdates(with: accuracy)
            }
        }
    }
    
    /// Restarts location updates with a new interval
    private func restartLocationUpdates(with accuracy: CLLocationAccuracy) {
        // Store current timer state
        let wasRunning = locationUpdateTimer != nil
        
        if wasRunning {
            stopUpdatingLocation()
            
            // Restart with new interval
            queue.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.startUpdatingLocation(with: accuracy)
            }
        }
    }
    

    // MARK: - One-Time Location Request
    /// Requests the user's location **once** (single update)
    /// - Apple Docs: ["Requests the one-time delivery of the user's current location."](https://developer.apple.com/documentation/corelocation/cllocationmanager/requestlocation)
    func requestLocation(with accuracy: CLLocationAccuracy) async {
        do {
            // Use the robust fallback mechanism
            let location = try await requestLocationWithFallback(for: accuracy)
            
            // Apply distance filter before reporting location
            if shouldReportLocation(location) {
                updateLastReportedLocation(location)
                checkStationaryStatus(location)
                checkRegionBoundaries(for: location)
                
                // Don't report location if paused due to being stationary
                if !isPaused {
                    delegate?.locationManagerService(self, didUpdateLocation: location)
                }
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
        
        currentProvider = provider

        // Use adaptive interval based on background mode and stationary status
        let interval = currentUpdateInterval

        // Start the timer with the adaptive interval
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: interval)

        timer.setEventHandler { [weak self] in
            Task {
                await self?.requestLocation(with: accuracy)
            }
        }

        locationUpdateTimer = timer // Store the timer reference
        timer.resume() // Start the timer
        
        print("[CLLocationManagerService] Started location updates with interval: \(interval)s")
    }

    func stopUpdatingLocation() {
        locationUpdateTimer?.cancel()
        locationUpdateTimer = nil
        
        // Reset distance filter tracking when stopping location updates
        resetDistanceFilter()
    }
    
    // MARK: - Region Monitoring
    
    /// Starts monitoring a region for entry and exit events
    func startMonitoring(for region: CLRegion) {
        regionMonitoringQueue.async(flags: .barrier) {
            self.monitoredRegions.insert(region)
            self.regionStates[region.identifier] = .unknown
        }
    }
    
    /// Stops monitoring a region
    func stopMonitoring(for region: CLRegion) {
        regionMonitoringQueue.async(flags: .barrier) {
            self.monitoredRegions.remove(region)
            self.regionStates.removeValue(forKey: region.identifier)
        }
    }
    
    /// Requests the current state of a region
    func requestState(for region: CLRegion) {
        guard let currentLocation = lastReportedLocation else {
            // If no location available, can't determine state
            delegate?.locationManagerService(self, didDetermineState: .unknown, for: region)
            return
        }
        
        let currentState = determineRegionState(for: region, at: currentLocation)
        regionMonitoringQueue.async(flags: .barrier) {
            self.regionStates[region.identifier] = currentState
        }
        delegate?.locationManagerService(self, didDetermineState: currentState, for: region)
    }
    
    /// Determines the current state of a region based on location
    private func determineRegionState(for region: CLRegion, at location: SendableCLLocation) -> CLRegionState {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        return region.contains(coordinate) ? .inside : .outside
    }
    
    /// Checks all monitored regions for boundary crossings when location updates
    private func checkRegionBoundaries(for newLocation: SendableCLLocation) {
        regionMonitoringQueue.async { [weak self] in
            guard let self = self else { return }
            
            
            for region in self.monitoredRegions {
                let previousState = self.regionStates[region.identifier] ?? .unknown
                let currentState = self.determineRegionState(for: region, at: newLocation)
                
                // Update stored state
                self.regionStates[region.identifier] = currentState
                
                // Check for state transitions and notify accordingly
                if previousState != currentState && previousState != .unknown {
                    switch (previousState, currentState) {
                    case (.outside, .inside):
                        if region.notifyOnEntry {
                            DispatchQueue.main.async {
                                self.delegate?.locationManagerService(self, didEnterRegion: region)
                            }
                        }
                    case (.inside, .outside):
                        if region.notifyOnExit {
                            DispatchQueue.main.async {
                                self.delegate?.locationManagerService(self, didExitRegion: region)
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
}

// MARK: - CLLocationManagerServiceDelegate
internal protocol CLLocationManagerServiceDelegate: AnyObject {
    func locationManagerService(_ service: CLLocationManagerService, didUpdateLocation location: SendableCLLocation)
    func locationManagerService(_ service: CLLocationManagerService, didFailWithError error: Error)
    func locationManagerService(_ service: CLLocationManagerService, didEnterRegion region: CLRegion)
    func locationManagerService(_ service: CLLocationManagerService, didExitRegion region: CLRegion)
    func locationManagerService(_ service: CLLocationManagerService, didDetermineState state: CLRegionState, for region: CLRegion)
    func locationManagerService(_ service: CLLocationManagerService, monitoringDidFailFor region: CLRegion?, withError error: Error)
}
