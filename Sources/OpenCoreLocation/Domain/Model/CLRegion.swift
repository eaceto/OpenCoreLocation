import Foundation

// MARK: - CLRegion
/// A geographic region that you monitor using location services.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clregion)
open class CLRegion: NSObject, NSCopying, NSSecureCoding {

    /// The unique identifier for the region.
    public let identifier: String

    /// The center point of the region (latitude and longitude).
    public let center: CLLocationCoordinate2D

    /// The radius of the region in meters.
    public let radius: CLLocationDistance

    /// Indicates whether the region triggers entry events.
    public var notifyOnEntry: Bool = true

    /// Indicates whether the region triggers exit events.
    public var notifyOnExit: Bool = true

    // MARK: - Secure Coding Conformance
    /// Required for `NSSecureCoding`
    public static var supportsSecureCoding: Bool = true

    /// Initializes a region with the specified center and radius.
    /// - Parameters:
    ///   - center: The geographical center of the region.
    ///   - radius: The radius of the region in meters.
    ///   - identifier: A unique string identifier for the region.
    public init(center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        self.center = center
        self.radius = radius
        self.identifier = identifier
    }

    /// Decodes an instance of `CLRegion` from an `NSCoder`.
    /// - Parameter coder: The `NSCoder` object used for decoding.
    required public init?(coder: NSCoder) {
        guard let identifier = coder.decodeObject(of: NSString.self, forKey: "identifier") as String? else {
            return nil
        }

        let latitude = coder.decodeDouble(forKey: "latitude")
        let longitude = coder.decodeDouble(forKey: "longitude")
        let radius = coder.decodeDouble(forKey: "radius")
        let notifyOnEntry = coder.decodeBool(forKey: "notifyOnEntry")
        let notifyOnExit = coder.decodeBool(forKey: "notifyOnExit")

        self.identifier = identifier
        self.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.radius = radius
        self.notifyOnEntry = notifyOnEntry
        self.notifyOnExit = notifyOnExit
    }

    /// Encodes an instance of `CLRegion` into an `NSCoder`.
    /// - Parameter coder: The `NSCoder` object used for encoding.
    public func encode(with coder: NSCoder) {
        coder.encode(identifier as NSString, forKey: "identifier")
        coder.encode(center.latitude, forKey: "latitude")
        coder.encode(center.longitude, forKey: "longitude")
        coder.encode(radius, forKey: "radius")
        coder.encode(notifyOnEntry, forKey: "notifyOnEntry")
        coder.encode(notifyOnExit, forKey: "notifyOnExit")
    }

    /// Checks whether a specific coordinate is inside the region.
    /// - Parameter coordinate: The coordinate to check.
    /// - Returns: A Boolean indicating if the coordinate is within the region's boundaries.
    public func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let distance = CLLocationDistance(
            sqrt(pow(coordinate.latitude - center.latitude, 2) + pow(coordinate.longitude - center.longitude, 2)) * 111000
        )
        return distance <= radius
    }

    // MARK: - NSCopying Conformance
    /// Creates a copy of this `CLRegion` instance.
    /// - Parameter zone: The zone in which to allocate the new object (default: `nil`).
    /// - Returns: A new `CLRegion` object with the same properties.
    public func copy(with zone: NSZone? = nil) -> Any {
        let regionCopy = CLRegion(center: center, radius: radius, identifier: identifier)
        regionCopy.notifyOnEntry = self.notifyOnEntry
        regionCopy.notifyOnExit = self.notifyOnExit
        return regionCopy
    }

    // MARK: - Hashable Conformance
    public static func == (lhs: CLRegion, rhs: CLRegion) -> Bool {
        return lhs.identifier == rhs.identifier &&
        lhs.center.latitude == rhs.center.latitude &&
        lhs.center.longitude == rhs.center.longitude &&
        lhs.radius == rhs.radius
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CLRegion else { return false }
        return self == other
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(center.latitude)
        hasher.combine(center.longitude)
        hasher.combine(radius)
        return hasher.finalize()
    }
}
