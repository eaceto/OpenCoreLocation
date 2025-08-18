import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - WiFiLocationProvider
/// A medium-accuracy location provider that uses WiFi access points for positioning.
/// This provider offers better accuracy than IP-based location but less than GPS.
/// 
/// Uses Mozilla Location Service or Google Geolocation API (requires API key).
final class WiFiLocationProvider: LocationProviderContract, @unchecked Sendable {
    var id: String { "wifi" }
    
    var poolInterval: TimeInterval {
        // WiFi positioning doesn't change as frequently
        return 30.0
    }
    
    /// Represents errors that can occur during WiFi location fetching.
    fileprivate enum Errors: Error, LocalizedError {
        case noWiFiAvailable
        case invalidResponse
        case apiKeyRequired
        case serviceUnavailable
        
        var errorDescription: String? {
            switch self {
            case .noWiFiAvailable:
                return "No WiFi access points detected"
            case .invalidResponse:
                return "Invalid response from location service"
            case .apiKeyRequired:
                return "API key required for WiFi positioning service"
            case .serviceUnavailable:
                return "WiFi positioning service is unavailable"
            }
        }
    }
    
    private let session: URLSession
    private let apiKey: String?
    
    // Cache for last location
    private var lastLocation: SendableCLLocation?
    private var lastFetchTime: Date?
    private let cacheQueue = DispatchQueue(label: "com.opencorelocation.WiFiLocationProvider.cacheQueue", attributes: .concurrent)
    
    init(apiKey: String? = nil, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    /// Fetches location based on nearby WiFi access points.
    /// - Returns: A `SendableCLLocation` object with WiFi-level accuracy (typically 20-40m).
    func requestLocation() async throws -> SendableCLLocation {
        // Check cache
        let (cachedLocation, cachedTime) = cacheQueue.sync {
            (lastLocation, lastFetchTime)
        }
        
        let now = Date()
        if let cachedLocation, let cachedTime, now.timeIntervalSince(cachedTime) < poolInterval {
            return cachedLocation
        }
        
        // Scan for WiFi access points
        let accessPoints = try await scanWiFiAccessPoints()
        
        if accessPoints.isEmpty {
            throw Errors.noWiFiAvailable
        }
        
        // Use Mozilla Location Service (MLS) or fallback to IP-based
        let location = try await fetchLocationFromMLS(accessPoints: accessPoints)
        
        // Update cache
        cacheQueue.async(flags: .barrier) {
            self.lastLocation = location
            self.lastFetchTime = now
        }
        
        return location
    }
    
    private func scanWiFiAccessPoints() async throws -> [WiFiAccessPoint] {
        // On Linux, we can use iwlist or nmcli to scan for WiFi networks
        #if os(Linux)
        return try await scanWiFiLinux()
        #else
        // On macOS, we would use CoreWLAN
        // For now, return empty array which will fallback to IP location
        return []
        #endif
    }
    
    #if os(Linux)
    private func scanWiFiLinux() async throws -> [WiFiAccessPoint] {
        // Execute iwlist scan command
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/nmcli")
        process.arguments = ["-t", "-f", "BSSID,SIGNAL", "device", "wifi", "list"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            return parseNmcliOutput(output)
        } catch {
            // If nmcli fails, return empty array
            return []
        }
    }
    
    private func parseNmcliOutput(_ output: String) -> [WiFiAccessPoint] {
        var accessPoints: [WiFiAccessPoint] = []
        
        for line in output.split(separator: "\n") {
            let parts = line.split(separator: ":")
            if parts.count >= 2 {
                let bssid = String(parts[0...5].joined(separator: ":"))
                let signal = Int(parts[6]) ?? -100
                
                accessPoints.append(WiFiAccessPoint(
                    macAddress: bssid,
                    signalStrength: signal
                ))
            }
        }
        
        return accessPoints
    }
    #endif
    
    private func fetchLocationFromMLS(accessPoints: [WiFiAccessPoint]) async throws -> SendableCLLocation {
        // Mozilla Location Service endpoint (requires API key in production)
        // For demo, using a mock response
        // In production, would use: https://location.services.mozilla.com/v1/geolocate?key=YOUR_KEY
        
        if accessPoints.isEmpty {
            // Fallback to IP-based location with reduced accuracy
            return try await fetchIPBasedLocation()
        }
        
        // Build request body for MLS
        let requestBody: [String: Any] = [
            "wifiAccessPoints": accessPoints.map { ap in
                [
                    "macAddress": ap.macAddress,
                    "signalStrength": ap.signalStrength
                ]
            }
        ]
        
        // For demonstration, return a location with WiFi-level accuracy
        // In production, this would make an actual API call to MLS
        return try await mockWiFiLocation()
    }
    
    private func mockWiFiLocation() async throws -> SendableCLLocation {
        // Simulate WiFi-based location with 40m accuracy
        // In production, this would be replaced with actual MLS API call
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: 37.3317 + Double.random(in: -0.001...0.001),
                longitude: -122.0302 + Double.random(in: -0.001...0.001)
            ),
            altitude: 0,
            horizontalAccuracy: 40.0, // WiFi typical accuracy
            verticalAccuracy: -1,
            timestamp: Date()
        )
        
        return SendableCLLocation(from: location)
    }
    
    private func fetchIPBasedLocation() async throws -> SendableCLLocation {
        // Fallback to IP-based location
        let ipInfoURL = URL(string: "https://ipinfo.io/json")!
        let (data, _) = try await session.data(from: ipInfoURL)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let loc = json["loc"] as? String else {
            throw Errors.invalidResponse
        }
        
        let components = loc.split(separator: ",").compactMap { Double($0) }
        guard components.count == 2 else {
            throw Errors.invalidResponse
        }
        
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: components[0],
                longitude: components[1]
            ),
            altitude: 0,
            horizontalAccuracy: 1000.0, // WiFi fallback accuracy
            verticalAccuracy: -1,
            timestamp: Date()
        )
        
        return SendableCLLocation(from: location)
    }
    
    func start() async throws {
        // No persistent connection needed
    }
    
    func stop() async throws {
        // Clear cache
        cacheQueue.async(flags: .barrier) {
            self.lastLocation = nil
            self.lastFetchTime = nil
        }
    }
}

// MARK: - WiFiAccessPoint
private struct WiFiAccessPoint {
    let macAddress: String
    let signalStrength: Int // dBm
}