import Foundation

public protocol LocationProviderContract: Identifiable, Sendable {
    /// An identifier for the location provider
    var id: String { get }

    /// Requests a location asynchronously
    /// - Returns: A `CLLocation` if successful, or throws an error if the request fails
    func requestLocation() async throws -> SendableCLLocation

    /// Optional method to start location updates, if applicable
    func start() async throws

    /// Optional method to stop location updates, if applicable
    func stop() async throws

    /// Number of seconds to check for new location when startUpdatingLocation
    var poolInterval: TimeInterval { get }
}

extension LocationProviderContract {
    var id: String { UUID().uuidString }
    public func start() async {}
    public func stop() async {}
    var poolInterval: TimeInterval { 60 }
}
