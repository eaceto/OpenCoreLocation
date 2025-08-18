import Foundation

// MARK: - CLLocationManager
/// The object you use to start and stop the delivery of location-related events to your app.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager)
open class CLLocationManager: NSObject {
    // MARK: - Delegates and Authorization
    /// The delegate object to receive update events.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/delegate)
    open weak var delegate: (any CLLocationManagerDelegate)?

    /// The current authorization status for the app.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/authorizationstatus)
    open var authorizationStatus: CLAuthorizationStatus = .notDetermined

    /// The level of location accuracy the app has permission to use.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/accuracyauthorization)
    open private(set) var accuracyAuthorization: CLAccuracyAuthorization = .fullAccuracy

    /// Indicates whether a widget is eligible to receive location updates.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/isauthorizedforwidgetupdates)
    open private(set) var isAuthorizedForWidgetUpdates: Bool = false

    // MARK: - Configuration Properties
    /// The type of activity the app expects the user to perform during location updates.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/activitytype)
    open var activityType: CLActivityType = .other

    /// The minimum distance (measured in meters) a device must move before an update event is generated.
    /// 
    /// - Note: Set to `kCLDistanceFilterNone` to disable distance filtering and receive all location updates.
    ///         Values less than or equal to 0 disable the filter. Default is 10.0 meters.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/distancefilter)
    open var distanceFilter: CLLocationDistance = 10.0 {
        didSet {
            // Update the service implementation with the new distance filter
            serviceImplementation.setDistanceFilter(distanceFilter)
        }
    }

    /// The accuracy of the location data that your app wants to receive.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/desiredaccuracy)
    open var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest

    /// A Boolean value that indicates whether the location manager may pause location updates.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/pauseslocationupdatesautomatically)
    open var pausesLocationUpdatesAutomatically: Bool = false

    /// A Boolean value that indicates whether the app receives location updates when running in the background.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/allowsbackgroundlocationupdates)
    open var allowsBackgroundLocationUpdates: Bool = false

    // MARK: - Location and Heading Properties
    /// The most recently retrieved user location.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/location)
    open private(set) var location: CLLocation?

    /// The minimum angular change (measured in degrees) required to generate new heading events.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/headingfilter)
    open var headingFilter: CLLocationDegrees = 1.0

    /// The device orientation to use when computing heading values.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/headingorientation)
    open var headingOrientation: CLDeviceOrientation = .portrait

    /// The most recently reported heading.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/heading)
    open private(set) var heading: CLHeading?

    // MARK: - Monitoring and Ranging
    /// The largest boundary distance that can be assigned to a region.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/maximumregionmonitoringdistance)
    open var maximumRegionMonitoringDistance: CLLocationDistance = 1000.0

    /// The set of shared regions monitored by all location-manager objects.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/monitoredregions)
    open private(set) var monitoredRegions: Set<CLRegion> = []

    /// The set of beacon constraints currently being tracked using ranging.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/rangedbeaconconstraints)
    open private(set) var rangedBeaconConstraints: Set<CLBeaconIdentityConstraint> = []

    // MARK: - Service Integration
    private let serviceImplementation: CLLocationManagerService
    public override init() {
        serviceImplementation = CLLocationManagerService()
        super.init()
        
        // Initialize service with current distance filter setting
        serviceImplementation.setDistanceFilter(distanceFilter)
    }

    // MARK: - Authorization Methods
    open func requestWhenInUseAuthorization() {
        authorizationStatus = .authorizedWhenInUse
        delegate?.locationManager(self, didChangeAuthorization: authorizationStatus)
    }

    open func requestAlwaysAuthorization() {
        authorizationStatus = .authorizedAlways
        delegate?.locationManager(self, didChangeAuthorization: authorizationStatus)
    }

    open func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String, completion: ((Error?) -> Void)? = nil) {
        accuracyAuthorization = .fullAccuracy
        completion?(nil)
        delegate?.locationManager(self, didChangeAccuracyAuthorization: accuracyAuthorization)
    }

    // MARK: - Location Management
    /// Starts the generation of updates that report the user’s current location.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/startupdatinglocation())
    /// - Calls `requestLocation(with:)` at provider-defined intervals (`poolInterval`).
    open func startUpdatingLocation() {
        serviceImplementation.delegate = self
        serviceImplementation.startUpdatingLocation(with: desiredAccuracy)
    }

    /// Stops all location updates
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/stopupdatinglocation())
    open func stopUpdatingLocation() {
        location = nil
        serviceImplementation.stopUpdatingLocation()
    }

    /// Requests the one-time delivery of the user’s current location.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/requestlocation())
    open func requestLocation() {
        serviceImplementation.delegate = self
        Task {
            await serviceImplementation.requestLocation(with: desiredAccuracy)
        }
    }

    // MARK: - Heading Management
    /// Starts the generation of updates that report the user's current heading.
    /// 
    /// - Note: Heading updates require magnetometer hardware which is not available on Linux.
    ///         This method is a no-op on Linux platforms and will not generate heading updates.
    ///         Use `headingAvailable()` to check if heading services are available.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/startupdatingheading())
    open func startUpdatingHeading() {
        // Heading updates are not supported on Linux due to lack of magnetometer hardware
        // This is a no-op to maintain API compatibility
    }

    /// Stops the generation of heading updates.
    /// 
    /// - Note: This method is a no-op on Linux platforms since heading updates are not supported.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/stopupdatingheading())
    open func stopUpdatingHeading() {
        // Heading updates are not supported on Linux
        // This is a no-op to maintain API compatibility
    }

    // MARK: - Service Availability
    /// Returns a Boolean value indicating whether location services are enabled on the device.
    open class func locationServicesEnabled() -> Bool {
        return true
    }

    /// Returns a Boolean value indicating whether the location manager is able to generate heading-related events.
    /// 
    /// - Returns: Always returns `false` on Linux platforms as magnetometer hardware is not available.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/headingavailable())
    open class func headingAvailable() -> Bool {
        // Heading services require magnetometer hardware which is not available on Linux
        return false
    }

    /// Returns a Boolean value indicating whether the significant-change location service is available on the device.
    /// 
    /// - Returns: Always returns `false` on Linux platforms as this service requires OS-level support not available on Linux.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/significantlocationchangemonitoringavailable())
    open class func significantLocationChangeMonitoringAvailable() -> Bool {
        // Significant location change monitoring requires OS-level support not available on Linux
        return false
    }

    /// Returns a Boolean value indicating whether the device supports region monitoring using the specified class.
    /// 
    /// - Parameter regionClass: The class of region to check support for.
    /// - Returns: Always returns `false` on Linux platforms as region monitoring requires OS-level support not available on Linux.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/ismonitoringavailable(for:))
    open class func isMonitoringAvailable(for regionClass: AnyClass) -> Bool {
        // Region monitoring requires OS-level geofencing support not available on Linux
        return false
    }

    /// Returns a Boolean value indicating whether the device supports ranging of beacons that use the iBeacon protocol.
    /// 
    /// - Returns: Always returns `false` on Linux platforms as beacon ranging requires Bluetooth LE hardware integration.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/israngingavailable())
    open class func isRangingAvailable() -> Bool {
        // Beacon ranging requires Bluetooth LE hardware integration not available on Linux
        return false
    }
}

extension CLLocationManager: CLLocationManagerServiceDelegate {
    func locationManagerService(_ service: CLLocationManagerService, didUpdateLocation location: SendableCLLocation) {
        let mappedLocation = location.toCLLocation()
        self.location = mappedLocation
        delegate?.locationManager(self, didUpdateLocations: [mappedLocation])
    }

    func locationManagerService(_ service: CLLocationManagerService, didFailWithError error: any Error) {
        delegate?.locationManager(self, didFailWithError: error)
    }
}
