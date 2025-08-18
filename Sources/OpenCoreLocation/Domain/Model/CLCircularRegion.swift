import Foundation

// MARK: - CLCircularRegion
/// A circular geographic region that you monitor using location services.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clcircularregion)
open class CLCircularRegion: CLRegion {
    
    // MARK: - Initialization
    
    /// Creates a circular region with the specified center point and radius.
    /// - Parameters:
    ///   - center: The center point of the circular region.
    ///   - radius: The radius of the circular region in meters.
    ///   - identifier: A unique identifier for the region.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clcircularregion/1423697-init)
    public override init(center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        super.init(center: center, radius: radius, identifier: identifier)
    }
    
    /// Creates a circular region from an `NSCoder`.
    /// - Parameter coder: The `NSCoder` object used for decoding.
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Testing Coordinate Containment
    
    /// Returns a Boolean value indicating whether the specified coordinate is inside the region.
    /// - Parameter coordinate: The coordinate to test.
    /// - Returns: `true` if the coordinate is inside the region; otherwise, `false`.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clcircularregion/1423564-contains)
    public override func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        // Use the parent class implementation which already uses haversine formula
        return super.contains(coordinate)
    }
    
    // MARK: - NSCopying Conformance
    
    /// Creates a copy of this `CLCircularRegion` instance.
    /// - Parameter zone: The zone in which to allocate the new object (default: `nil`).
    /// - Returns: A new `CLCircularRegion` object with the same properties.
    public override func copy(with zone: NSZone? = nil) -> Any {
        let regionCopy = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        regionCopy.notifyOnEntry = self.notifyOnEntry
        regionCopy.notifyOnExit = self.notifyOnExit
        return regionCopy
    }
}