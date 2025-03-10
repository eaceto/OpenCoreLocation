import Foundation

/// The authorization status for the application, indicating whether it can use location services.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clauthorizationstatus)
public enum CLAuthorizationStatus: String {
    /// The user has not yet made a choice regarding whether this app can use location services.
    case notDetermined = "Not Determined"
    /// This app is not authorized to use location services.
    /// The user cannot change this app’s status, possibly due to active restrictions
    /// such as parental controls being in place.
    case restricted = "Restricted"
    /// The user explicitly denied the use of location services for this app or
    /// location services are currently disabled in Settings.
    case denied = "Denied"
    /// This app is authorized to use location services only while it is in the foreground.
    case authorizedWhenInUse = "Authorized When In Use"
    /// This app is authorized to use location services at any time.
    case authorizedAlways = "Authorized Always"
}
