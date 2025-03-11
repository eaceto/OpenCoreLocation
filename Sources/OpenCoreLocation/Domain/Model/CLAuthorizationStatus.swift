import Foundation

/// The authorization status for the application, indicating whether it can use location services.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clauthorizationstatus)
public enum CLAuthorizationStatus: String, CustomDebugStringConvertible, CustomStringConvertible {
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

    // MARK: - CustomStringConvertible
    /// A user-friendly description of the authorization status.
    public var description: String {
        switch self {
        case .notDetermined:
            return "CLAuthorizationStatus(notDetermined)"
        case .restricted:
            return "CLAuthorizationStatus(restricted)"
        case .denied:
            return "CLAuthorizationStatus(denied)"
        case .authorizedWhenInUse:
            return "CLAuthorizationStatus(authorizedWhenInUse)"
        case .authorizedAlways:
            return "CLAuthorizationStatus(authorizedAlways)"
        }
    }

    // MARK: - CustomDebugStringConvertible
    /// A debug-friendly description of the authorization status.
    public var debugDescription: String {
        return description
    }
}
