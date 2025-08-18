import Foundation

// MARK: - CLLocationManagerDelegate
/// The `CLLocationManagerDelegate` protocol defines methods that you implement to receive and handle location-related events.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate)
public protocol CLLocationManagerDelegate: AnyObject {
    /// Tells the delegate that new location data is available.
    /// - Parameters:
    ///   - manager: The location manager object that generated the update event.
    ///   - locations: An array of `CLLocation` objects representing the new location data.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])

    /// Tells the delegate that the location manager was unable to retrieve a location value.
    /// - Parameters:
    ///   - manager: The location manager object that generated the error.
    ///   - error: An error object containing the reason why the location could not be retrieved.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)

    /// Tells the delegate that the authorization status changed for the application.
    /// - Parameters:
    ///   - manager: The location manager object reporting the authorization status.
    ///   - status: The new authorization status for the application.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)

    /// Tells the delegate that the heading information was updated.
    /// - Parameters:
    ///   - manager: The location manager object that generated the update event.
    ///   - newHeading: The new heading data.
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)

    /// Tells the delegate that the device's location accuracy authorization changed.
    /// - Parameters:
    ///   - manager: The location manager object reporting the change.
    ///   - accuracyAuthorization: The new accuracy authorization level.
    func locationManager(_ manager: CLLocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization)
    
    /// Tells the delegate that the user entered the specified region.
    /// - Parameters:
    ///   - manager: The location manager object that generated the event.
    ///   - region: The region that was entered.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
    
    /// Tells the delegate that the user left the specified region.
    /// - Parameters:
    ///   - manager: The location manager object that generated the event.
    ///   - region: The region that was exited.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
    
    /// Tells the delegate that a region monitoring error occurred.
    /// - Parameters:
    ///   - manager: The location manager object reporting the error.
    ///   - region: The region for which monitoring failed.
    ///   - error: An error object containing the reason for the failure.
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error)
    
    /// Tells the delegate that monitoring for a region started.
    /// - Parameters:
    ///   - manager: The location manager object that started monitoring the region.
    ///   - region: The region that is now being monitored.
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)
    
    /// Tells the delegate the state of the specified region.
    /// - Parameters:
    ///   - manager: The location manager object providing this update.
    ///   - state: The state of the specified region.
    ///   - region: The region whose state was determined.
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion)
}

// MARK: - Default Implementations
public extension CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {}
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {}
    func locationManager(_ manager: CLLocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {}
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {}
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {}
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {}
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {}
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {}
}
