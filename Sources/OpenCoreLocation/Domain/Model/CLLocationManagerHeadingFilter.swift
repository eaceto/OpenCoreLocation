import Foundation

/// The minimum angular change (measured in degrees) required to generate a heading update event.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/1615803-headingfilter)
public enum CLLocationManagerHeadingFilter: Double {
    /// All heading changes are reported.
    case none = 0.0
    /// A change of at least five degrees is required for an update.
    case fiveDegrees = 5.0
    /// A change of at least ten degrees is required for an update.
    case tenDegrees = 10.0
    /// A change of at least fifteen degrees is required for an update.
    case fifteenDegrees = 15.0
}
