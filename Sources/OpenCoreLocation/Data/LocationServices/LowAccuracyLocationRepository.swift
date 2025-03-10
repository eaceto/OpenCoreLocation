import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - LowAccuracyLocationRepository
/// A service that fetches the user's approximate location using the ipinfo.io API.
/// [API Documentation](https://ipinfo.io/developers)
final class LowAccuracyLocationProvider: LocationProviderContract, @unchecked Sendable {
    var id: String { "ipinfo.io" }

    var poolInterval: TimeInterval {
        #if os(Linux)
            30.0
        #else
            // 10 seconds in tests, 5 min in other scenarios
            NSClassFromString("XCTestCase") == nil ? 60.0 * 5.0 : 10.0
        #endif
    }

    /// Represents errors that can occur during location fetching.
    fileprivate enum Errors: Error {
        case invalidResponse
        case invalidData
    }

    private let ipInfoURL = URL(string: "https://ipinfo.io/json")!
    private let session: URLSession

    // Cache Variables (Protected by a Serial DispatchQueue)
    private var lastLocation: SendableCLLocation?
    private var lastFetchTime: Date?
    private let cacheQueue = DispatchQueue(label: "com.opencorelocation.cacheQueue", attributes: .concurrent)

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches the approximate location using the ipinfo.io API.
    /// - Returns: A `SendableCLLocation` object with the fetched latitude and longitude.
    func requestLocation() async throws -> SendableCLLocation {
        // Check cache before proceeding (thread-safe access)
        let (cachedLocation, cachedTime) = cacheQueue.sync {
            (lastLocation, lastFetchTime)
        }

        let now = Date()

        // Check if we can use the cached location
        if let cachedLocation, let cachedTime, now.timeIntervalSince(cachedTime) < poolInterval {
            return cachedLocation
        }

        // If expired, fetch a new location
        let (data, response) = try await session.data(from: ipInfoURL)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw LowAccuracyLocationProvider.Errors.invalidResponse
        }

        let ipInfo = try JSONDecoder().decode(IPInfoResponse.self, from: data)
        let newLocation = try SendableCLLocation(from: ipInfo.toLocation())

        // Update cache (thread-safe access)
        cacheQueue.async(flags: .barrier) {
            self.lastLocation = newLocation
            self.lastFetchTime = now
        }

        return newLocation
    }
}

// MARK: - IPInfoResponse
/// Represents the response structure from the ipinfo.io API.
private struct IPInfoResponse: Decodable {
    let loc: String

    func toLocation() throws -> CLLocation {
        let components = loc.split(separator: ",").compactMap { Double($0) }
        guard components.count == 2 else {
            throw LowAccuracyLocationProvider.Errors.invalidData
        }
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: components[0],
                                                             longitude: components[1]),
                          altitude: 0,
                          horizontalAccuracy: 20_000,
                          verticalAccuracy: 0,
                          timestamp: Date()
        )
    }
}
