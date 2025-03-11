import Foundation

/// A thread-safe, sendable representation of `CLLocation`.
/// This struct is designed to encapsulate the key properties of `CLLocation`
/// while ensuring it is safe to use in concurrent and isolated execution contexts.
public struct SendableCLLocation: Sendable, CustomStringConvertible, CustomDebugStringConvertible {

    // MARK: - Properties

    /// The latitude of the location.
    public let latitude: Double

    /// The longitude of the location.
    public let longitude: Double

    /// The altitude of the location in meters.
    public let altitude: Double

    /// The horizontal accuracy of the location in meters.
    public let horizontalAccuracy: Double

    /// The vertical accuracy of the location in meters.
    public let verticalAccuracy: Double

    /// The timestamp when the location was determined.
    public let timestamp: Date

    /// The course of the device in degrees relative to true north.
    /// - Range: `0.0` - `359.9` degrees (`0` being true north). Negative if course is invalid.
    public let course: Double

    /// The accuracy of the course measurement in degrees.
    public let courseAccuracy: Double

    /// The speed of the device in meters per second.
    public let speed: Double

    /// The accuracy of the speed measurement in meters per second.
    public let speedAccuracy: Double

    // MARK: - Initialization

    /// Initializes a new `SendableCLLocation` instance.
    public init(
        latitude: Double,
        longitude: Double,
        altitude: Double = 0.0,
        horizontalAccuracy: Double = 0.0,
        verticalAccuracy: Double = 0.0,
        course: Double = -1.0,
        courseAccuracy: Double = -1.0,
        speed: Double = -1.0,
        speedAccuracy: Double = -1.0,
        timestamp: Date = Date()
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.course = course
        self.courseAccuracy = courseAccuracy
        self.speed = speed
        self.speedAccuracy = speedAccuracy
        self.timestamp = timestamp
    }

    // MARK: - CustomStringConvertible

    /// Returns a user-friendly string representation of the location.
    public var description: String {
        return "<SendableCLLocation: \(latitude), \(longitude) ±\(horizontalAccuracy)m @ \(timestamp)>"
    }

    // MARK: - CustomDebugStringConvertible

    /// Returns a detailed string representation for debugging.
    public var debugDescription: String {
        return """
        SendableCLLocation(
            latitude: \(latitude),
            longitude: \(longitude),
            altitude: \(altitude),
            horizontalAccuracy: \(horizontalAccuracy),
            verticalAccuracy: \(verticalAccuracy),
            course: \(course),
            courseAccuracy: \(courseAccuracy),
            speed: \(speed),
            speedAccuracy: \(speedAccuracy),
            timestamp: \(timestamp)
        )
        """
    }
}

// MARK: - Conversion Extensions
extension SendableCLLocation {

    /// Initializes a `SendableCLLocation` from a `CLLocation`
    public init(from location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.course = location.course
        self.courseAccuracy = location.courseAccuracy
        self.speed = location.speed
        self.speedAccuracy = location.speedAccuracy
        self.timestamp = location.timestamp
    }

    /// Converts the `SendableCLLocation` back into a `CLLocation`
    public func toCLLocation() -> CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy,
            course: course,
            courseAccuracy: courseAccuracy,
            speed: speed,
            speedAccuracy: speedAccuracy,
            timestamp: timestamp
        )
    }
}
