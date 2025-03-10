import Foundation

/// The state of a region relative to the user’s location.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clregionstate)
public enum CLRegionState: String {
    /// The state of the region is unknown.
    case unknown = "Unknown"
    /// The user is inside the region.
    case inside = "Inside"
    /// The user is outside the region.
    case outside = "Outside"
}
