import Foundation

/// The relation between the user’s device and a nearby beacon.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clproximity)
public enum CLProximity: String {
    /// The proximity of the beacon could not be determined.
    case unknown = "Unknown"
    /// The beacon is immediately adjacent to the device.
    case immediate = "Immediate"
    /// The beacon is nearby, but not immediately adjacent to the device.
    case near = "Near"
    /// The beacon is far away from the device.
    case far = "Far"
}
