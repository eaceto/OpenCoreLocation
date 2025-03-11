import Foundation

// MARK: - CLBeaconIdentityConstraint
/// Represents the constraints used to identify a specific iBeacon.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clbeaconidentityconstraint)
public struct CLBeaconIdentityConstraint: Hashable, CustomDebugStringConvertible, CustomStringConvertible {
    /// The unique identifier of the beacon's proximity UUID.
    public let uuid: UUID

    /// The major value that identifies one or more beacons (optional).
    public let major: UInt16?

    /// The minor value that identifies a specific beacon (optional).
    public let minor: UInt16?

    /// Initializes a constraint for a specific beacon.
    /// - Parameters:
    ///   - uuid: The proximity UUID of the beacon.
    ///   - major: The major value (optional).
    ///   - minor: The minor value (optional).
    public init(uuid: UUID, major: UInt16? = nil, minor: UInt16? = nil) {
        self.uuid = uuid
        self.major = major
        self.minor = minor
    }

    // MARK: - CustomStringConvertible
    /// A user-friendly description of the beacon identity constraint.
    public var description: String {
        var result = "CLBeaconIdentityConstraint(uuid: \(uuid.uuidString)"
        if let major = major {
            result += ", major: \(major)"
        }
        if let minor = minor {
            result += ", minor: \(minor)"
        }
        result += ")"
        return result
    }

    // MARK: - CustomDebugStringConvertible
    /// A debug-friendly description of the beacon identity constraint.
    public var debugDescription: String {
        return description
    }
}
