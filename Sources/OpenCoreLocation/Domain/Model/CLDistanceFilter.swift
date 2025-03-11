import Foundation

/// The minimum distance (measured in meters) a device must move before an update event is generated.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620558-distancefilter)
public enum CLDistanceFilter: Double, CustomDebugStringConvertible, CustomStringConvertible {
    /// All movement is reported.
    case none = 0.0
    /// Movement of at least ten meters is required for an update.
    case tenMeters = 10.0
    /// Movement of at least fifty meters is required for an update.
    case fiftyMeters = 50.0
    /// Movement of at least a hundred meters is required for an update.
    case hundredMeters = 100.0

    // MARK: - CustomStringConvertible
    /// A user-friendly description of the distance filter.
    public var description: String {
        switch self {
        case .none:
            return "No minimum movement required"
        case .tenMeters:
            return "Minimum movement: 10 meters"
        case .fiftyMeters:
            return "Minimum movement: 50 meters"
        case .hundredMeters:
            return "Minimum movement: 100 meters"
        }
    }

    // MARK: - CustomDebugStringConvertible
    /// A debug-friendly description of the distance filter.
    public var debugDescription: String {
        return "CLDistanceFilter(\(rawValue) meters)"
    }
}
