import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - GPSLocationProvider
/// A high-accuracy location provider that connects to gpsd (GPS daemon) on Linux systems.
/// This provider offers the highest accuracy by using real GPS hardware when available.
/// 
/// Requirements:
/// - gpsd must be installed and running on the system
/// - Default connection is to localhost:2947
/// 
/// Installation on Linux:
/// ```bash
/// sudo apt-get install gpsd gpsd-clients
/// sudo systemctl start gpsd
/// ```
final class GPSLocationProvider: LocationProviderContract, @unchecked Sendable {
    var id: String { "gpsd" }
    
    var poolInterval: TimeInterval {
        // GPS can provide frequent updates
        return 1.0
    }
    
    /// Represents errors that can occur during GPS location fetching.
    fileprivate enum Errors: Error, LocalizedError {
        case gpsdNotAvailable
        case invalidResponse
        case noFixAvailable
        case connectionFailed
        
        var errorDescription: String? {
            switch self {
            case .gpsdNotAvailable:
                return "GPS daemon (gpsd) is not available or not running"
            case .invalidResponse:
                return "Invalid response from GPS daemon"
            case .noFixAvailable:
                return "No GPS fix available"
            case .connectionFailed:
                return "Failed to connect to GPS daemon"
            }
        }
    }
    
    private let gpsdHost: String
    private let gpsdPort: Int
    private let session: URLSession
    
    // Cache for last known good location
    private var lastLocation: SendableCLLocation?
    private var lastFetchTime: Date?
    private let cacheQueue = DispatchQueue(label: "com.opencorelocation.GPSLocationProvider.cacheQueue", attributes: .concurrent)
    
    init(host: String = "localhost", port: Int = 2947, session: URLSession = .shared) {
        self.gpsdHost = host
        self.gpsdPort = port
        self.session = session
    }
    
    /// Fetches the current GPS location from gpsd.
    /// - Returns: A `SendableCLLocation` object with GPS-level accuracy.
    func requestLocation() async throws -> SendableCLLocation {
        // Check cache for very recent location (within 1 second)
        let (cachedLocation, cachedTime) = cacheQueue.sync {
            (lastLocation, lastFetchTime)
        }
        
        let now = Date()
        if let cachedLocation, let cachedTime, now.timeIntervalSince(cachedTime) < 1.0 {
            return cachedLocation
        }
        
        // Try to get GPS data from gpsd
        do {
            let location = try await fetchGPSLocation()
            
            // Update cache
            cacheQueue.async(flags: .barrier) {
                self.lastLocation = location
                self.lastFetchTime = now
            }
            
            return location
        } catch {
            // If GPS fails and we have a cached location less than 30 seconds old, use it
            if let cachedLocation, let cachedTime, now.timeIntervalSince(cachedTime) < 30.0 {
                return cachedLocation
            }
            throw error
        }
    }
    
    private func fetchGPSLocation() async throws -> SendableCLLocation {
        // gpsd JSON API endpoint for current position
        let gpsdURL = URL(string: "http://\(gpsdHost):\(gpsdPort)/?WATCH={\"enable\":true,\"json\":true}")!
        
        // Try to connect to gpsd
        var request = URLRequest(url: gpsdURL)
        request.timeoutInterval = 5.0
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw Errors.connectionFailed
            }
            
            // gpsd returns streaming JSON, we need to parse the TPV (Time-Position-Velocity) object
            // For simplicity, we'll make a single poll request instead
            let pollURL = URL(string: "http://\(gpsdHost):\(gpsdPort)/?POLL;")!
            let pollRequest = URLRequest(url: pollURL)
            let (pollData, _) = try await session.data(for: pollRequest)
            
            return try parseGPSResponse(pollData)
        } catch {
            // If we can't connect to gpsd, throw appropriate error
            throw Errors.gpsdNotAvailable
        }
    }
    
    private func parseGPSResponse(_ data: Data) throws -> SendableCLLocation {
        // gpsd returns a JSON response with TPV (Time-Position-Velocity) data
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tpv = json["tpv"] as? [[String: Any]],
              let latestTPV = tpv.first else {
            throw Errors.invalidResponse
        }
        
        // Extract GPS data
        guard let mode = latestTPV["mode"] as? Int,
              mode >= 2, // 2D fix or better
              let lat = latestTPV["lat"] as? Double,
              let lon = latestTPV["lon"] as? Double else {
            throw Errors.noFixAvailable
        }
        
        // Extract optional fields with defaults
        let alt = latestTPV["alt"] as? Double ?? 0.0
        let speed = latestTPV["speed"] as? Double ?? -1.0 // m/s
        let course = latestTPV["track"] as? Double ?? -1.0 // degrees
        let horizontalAccuracy = latestTPV["epx"] as? Double ?? 5.0 // Error in meters
        let verticalAccuracy = latestTPV["epv"] as? Double ?? 10.0
        let speedAccuracy = latestTPV["eps"] as? Double ?? -1.0
        
        // Create CLLocation with GPS accuracy
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            altitude: alt,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy,
            course: course,
            courseAccuracy: -1.0, // gpsd doesn't provide course accuracy
            speed: speed,
            speedAccuracy: speedAccuracy,
            timestamp: Date()
        )
        
        return SendableCLLocation(from: location)
    }
    
    func start() async throws {
        // No persistent connection needed for polling mode
    }
    
    func stop() async throws {
        // Clear cache when stopping
        cacheQueue.async(flags: .barrier) {
            self.lastLocation = nil
            self.lastFetchTime = nil
        }
    }
}

// MARK: - GPSLocationProvider Linux Alternative
#if os(Linux)
extension GPSLocationProvider {
    /// Alternative implementation using gpsd socket protocol directly
    /// This is more efficient than HTTP polling but requires socket programming
    private func fetchGPSLocationViaSocket() async throws -> SendableCLLocation {
        // This would connect directly to gpsd socket on port 2947
        // and parse NMEA sentences or JSON stream
        // For now, we use the HTTP interface above
        throw Errors.gpsdNotAvailable
    }
}
#endif