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

    /// Tells the delegate that the device’s location accuracy authorization changed.
    /// - Parameters:
    ///   - manager: The location manager object reporting the change.
    ///   - accuracyAuthorization: The new accuracy authorization level.
    func locationManager(_ manager: CLLocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization)
}

// MARK: - Default Implementations
public extension CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {}
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {}
    func locationManager(_ manager: CLLocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {}
}
