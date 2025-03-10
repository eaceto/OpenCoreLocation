import Foundation

/// Represents different components of heading data.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clheading)
public enum CLHeadingComponent: String {
    /// The heading relative to the magnetic North Pole.
    case magneticHeading = "Magnetic Heading"
    /// The heading relative to the geographic North Pole.
    case trueHeading = "True Heading"
    /// The accuracy of the heading data in degrees.
    case headingAccuracy = "Heading Accuracy"
}
