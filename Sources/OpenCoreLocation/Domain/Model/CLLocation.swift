import Foundation

/// Represents a geographical coordinate along with accuracy, timestamp, and motion information.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation)
open class CLLocation: NSObject, NSCopying, NSSecureCoding {
    // MARK: - Properties

    /// The geographical coordinate of the location.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation/coordinate)
    public let coordinate: CLLocationCoordinate2D

    /// The altitude of the location in meters.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation/altitude)
    public let altitude: CLLocationDistance

    /// The timestamp when the location was determined.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation/timestamp)
    public let timestamp: Date

    /// The horizontal accuracy of the location in meters.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation/horizontalaccuracy)
    public let horizontalAccuracy: CLLocationAccuracy

    /// The vertical accuracy of the location in meters.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation/verticalaccuracy)
    public let verticalAccuracy: CLLocationAccuracy

    /// The direction of travel of the device in degrees relative to true north.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation/course)
    public let course: CLLocationDirection

    /// The accuracy of the course measurement in degrees.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation/courseaccuracy)
    public let courseAccuracy: CLLocationDirectionAccuracy

    /// The speed of the device in meters per second.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation/speed)
    public let speed: CLLocationSpeed

    /// The accuracy of the speed measurement in meters per second.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation/speedaccuracy)
    public let speedAccuracy: CLLocationSpeedAccuracy

    // MARK: - Additional Properties

    /// The floor level of the location (if available).
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation/floor)
    public let floor: CLFloor?

    /// Additional source information about how the location was determined.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocation/sourceinformation)
    public let sourceInformation: CLLocationSourceInformation?

    // MARK: - NSSecureCoding Conformance

    /// Indicates that `CLLocation` supports secure coding.
    /// [Apple Documentation](https://developer.apple.com/documentation/foundation/nssecurecoding)
    public static var supportsSecureCoding: Bool = true

    // MARK: - Initialization

    /// Initializes a new `CLLocation` object with latitude and longitude.
    /// - Parameters:
    ///   - latitude: The latitude of the location.
    ///   - longitude: The longitude of the location.
    public init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.altitude = 0.0
        self.horizontalAccuracy = -1.0
        self.verticalAccuracy = -1.0
        self.timestamp = Date()
        self.course = -1.0
        self.courseAccuracy = -1.0
        self.speed = -1.0
        self.speedAccuracy = -1.0
        self.floor = nil
        self.sourceInformation = nil
    }

    /// Initializes a `CLLocation` with full details including altitude, accuracy, speed, and course.
    public init(
        coordinate: CLLocationCoordinate2D,
        altitude: CLLocationDistance,
        horizontalAccuracy: CLLocationAccuracy,
        verticalAccuracy: CLLocationAccuracy,
        course: CLLocationDirection = -1.0,
        courseAccuracy: CLLocationDirectionAccuracy = -1.0,
        speed: CLLocationSpeed = -1.0,
        speedAccuracy: CLLocationSpeedAccuracy = -1.0,
        timestamp: Date,
        floor: CLFloor? = nil,
        sourceInformation: CLLocationSourceInformation? = nil
    ) {
        self.coordinate = coordinate
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.course = course
        self.courseAccuracy = courseAccuracy
        self.speed = speed
        self.speedAccuracy = speedAccuracy
        self.timestamp = timestamp
        self.floor = floor
        self.sourceInformation = sourceInformation
    }

    // MARK: - Distance Calculation

    /// Computes the great-circle distance between two locations.
    public func distance(from location: CLLocation) -> CLLocationDistance {
        let lat1 = coordinate.latitude * .pi / 180
        let lon1 = coordinate.longitude * .pi / 180
        let lat2 = location.coordinate.latitude * .pi / 180
        let lon2 = location.coordinate.longitude * .pi / 180

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let R: CLLocationDistance = 6371000 // Earth radius in meters

        return R * c
    }

    // MARK: - NSCopying Conformance

    /// Creates a copy of this `CLLocation` instance.
    public func copy(with zone: NSZone? = nil) -> Any {
        return CLLocation(
            coordinate: coordinate,
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy,
            course: course,
            courseAccuracy: courseAccuracy,
            speed: speed,
            speedAccuracy: speedAccuracy,
            timestamp: timestamp,
            floor: floor,
            sourceInformation: sourceInformation
        )
    }

    // MARK: - NSSecureCoding Conformance

    /// Initializes a `CLLocation` from an `NSCoder`.
    public required init?(coder: NSCoder) {
        let latitude = coder.decodeDouble(forKey: "latitude")
        let longitude = coder.decodeDouble(forKey: "longitude")
        let altitude = coder.decodeDouble(forKey: "altitude")
        let horizontalAccuracy = coder.decodeDouble(forKey: "horizontalAccuracy")
        let verticalAccuracy = coder.decodeDouble(forKey: "verticalAccuracy")
        let course = coder.decodeDouble(forKey: "course")
        let courseAccuracy = coder.decodeDouble(forKey: "courseAccuracy")
        let speed = coder.decodeDouble(forKey: "speed")
        let speedAccuracy = coder.decodeDouble(forKey: "speedAccuracy")
        let timestamp = coder.decodeObject(of: NSDate.self, forKey: "timestamp") as Date? ?? Date()
        let floor = coder.decodeObject(of: CLFloor.self, forKey: "floor")
        let sourceInformation = coder.decodeObject(of: CLLocationSourceInformation.self, forKey: "sourceInformation")

        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.course = course
        self.courseAccuracy = courseAccuracy
        self.speed = speed
        self.speedAccuracy = speedAccuracy
        self.timestamp = timestamp
        self.floor = floor
        self.sourceInformation = sourceInformation
    }

    /// Encodes this `CLLocation` into an `NSCoder`.
    public func encode(with coder: NSCoder) {
        coder.encode(coordinate.latitude, forKey: "latitude")
        coder.encode(coordinate.longitude, forKey: "longitude")
        coder.encode(altitude, forKey: "altitude")
        coder.encode(horizontalAccuracy, forKey: "horizontalAccuracy")
        coder.encode(verticalAccuracy, forKey: "verticalAccuracy")
        coder.encode(course, forKey: "course")
        coder.encode(courseAccuracy, forKey: "courseAccuracy")
        coder.encode(speed, forKey: "speed")
        coder.encode(speedAccuracy, forKey: "speedAccuracy")
        coder.encode(timestamp as NSDate, forKey: "timestamp")
        coder.encode(floor, forKey: "floor")
        coder.encode(sourceInformation, forKey: "sourceInformation")
    }
}
