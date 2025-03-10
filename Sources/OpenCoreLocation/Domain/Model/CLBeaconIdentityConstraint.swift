import Foundation

// MARK: - CLBeaconIdentityConstraint
/// Represents the constraints used to identify a specific iBeacon.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clbeaconidentityconstraint)
public struct CLBeaconIdentityConstraint: Hashable {
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
}
