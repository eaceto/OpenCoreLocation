import Foundation

/// Represents a geographic coordinate in degrees.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationcoordinate2d)
public struct CLLocationCoordinate2D: CustomDebugStringConvertible, CustomStringConvertible, Sendable {

    /// Initializes a coordinate with default values.
    public init() {
        self.latitude = 0.0
        self.longitude = 0.0
    }

    /// Initializes a coordinate with specific latitude and longitude.
    /// - Parameters:
    ///   - latitude: The latitude in degrees.
    ///   - longitude: The longitude in degrees.
    public init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /// The latitude of the coordinate in degrees.
    public var latitude: CLLocationDegrees

    /// The longitude of the coordinate in degrees.
    public var longitude: CLLocationDegrees

    // MARK: - CustomStringConvertible
    /// A user-friendly description of the coordinate.
    public var description: String {
        return "(\(latitude), \(longitude))"
    }

    // MARK: - CustomDebugStringConvertible
    /// A debug-friendly description of the coordinate.
    public var debugDescription: String {
        return "CLLocationCoordinate2D(latitude: \(latitude), longitude: \(longitude))"
    }
}

// MARK: - Special Constants
/// The maximum possible distance value.
public let CLLocationDistanceMax: CLLocationDistance = Double.greatestFiniteMagnitude

/// The maximum possible time interval value.
public let CLTimeIntervalMax: TimeInterval = Double.greatestFiniteMagnitude

// MARK: - Coordinate Validation
/// A constant representing an invalid coordinate.
public let kCLLocationCoordinate2DInvalid = CLLocationCoordinate2D(latitude: .nan, longitude: .nan)

/// Determines whether the given coordinate is valid.
/// - Parameter coord: The coordinate to check.
/// - Returns: `true` if the coordinate is valid; otherwise, `false`.
public func CLLocationCoordinate2DIsValid(_ coord: CLLocationCoordinate2D) -> Bool {
    return !(coord.latitude.isNaN || coord.longitude.isNaN)
}

/// Creates a `CLLocationCoordinate2D` object with the specified latitude and longitude.
/// - Parameters:
///   - latitude: The latitude in degrees.
///   - longitude: The longitude in degrees.
/// - Returns: A new `CLLocationCoordinate2D` object.
public func CLLocationCoordinate2DMake(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
}
