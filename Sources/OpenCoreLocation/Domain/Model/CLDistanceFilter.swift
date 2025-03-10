import Foundation

/// The minimum distance (measured in meters) a device must move before an update event is generated.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620558-distancefilter)
public enum CLDistanceFilter: Double {
    /// All movement is reported.
    case none = 0.0
    /// Movement of at least ten meters is required for an update.
    case tenMeters = 10.0
    /// Movement of at least fifty meters is required for an update.
    case fiftyMeters = 50.0
    /// Movement of at least a hundred meters is required for an update.
    case hundredMeters = 100.0
}
