import Foundation

/// Represents the logical floor level of a location inside a building.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clfloor)
public class CLFloor: NSObject, NSCopying, NSSecureCoding {

    // MARK: - Properties

    /// The floor level relative to the ground floor.
    ///
    /// - Floor `0` represents the ground floor.
    /// - Positive numbers indicate floors **above** ground level.
    /// - Negative numbers indicate floors **below** ground level (e.g., basements).
    ///
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clfloor/level)
    public let level: Int

    // MARK: - NSSecureCoding Conformance

    /// Indicates that `CLFloor` supports secure coding.
    /// [Apple Documentation](https://developer.apple.com/documentation/foundation/nssecurecoding)
    public static let supportsSecureCoding: Bool = true

    // MARK: - Initialization

    /// Creates a `CLFloor` instance with the specified floor level.
    /// - Parameter level: The logical floor number.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clfloor/init(level:))
    public init(level: Int) {
        self.level = level
    }

    // MARK: - NSCopying Conformance

    /// Creates a copy of this `CLFloor` instance.
    /// - Returns: A new `CLFloor` object with the same floor level.
    /// [Apple Documentation](https://developer.apple.com/documentation/foundation/nscopying)
    public func copy(with zone: NSZone? = nil) -> Any {
        return CLFloor(level: self.level)
    }

    // MARK: - NSSecureCoding Conformance

    /// Initializes a `CLFloor` from an `NSCoder`.
    /// - Parameter coder: The `NSCoder` instance used to decode the properties.
    public required init?(coder: NSCoder) {
        self.level = coder.decodeInteger(forKey: "level")
    }

    /// Encodes this `CLFloor` into an `NSCoder`.
    /// - Parameter coder: The `NSCoder` instance used to encode the properties.
    public func encode(with coder: NSCoder) {
        coder.encode(level, forKey: "level")
    }
}
