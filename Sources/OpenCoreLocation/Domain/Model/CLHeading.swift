import Foundation

/// Represents the heading information of a device.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clheading)
public class CLHeading {
    /// The heading relative to the magnetic North Pole.
    public let magneticHeading: Double
    /// The heading relative to the geographic North Pole.
    public let trueHeading: Double
    /// The accuracy of the heading data in degrees.
    public let headingAccuracy: Double
    /// The timestamp when the heading was determined.
    public let timestamp: Date

    public init(magneticHeading: Double, trueHeading: Double, headingAccuracy: Double, timestamp: Date = Date()) {
        self.magneticHeading = magneticHeading
        self.trueHeading = trueHeading
        self.headingAccuracy = headingAccuracy
        self.timestamp = timestamp
    }
}
