import Foundation
import OpenCoreLocation

/// Simple test to demonstrate provider fallback behavior
/// This shows which provider is actually being used when GPS is unavailable
@MainActor
class ProviderFallbackTest: CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var testCompleted = false
    
    func runTest() {
        print("🧪 Provider Fallback Test")
        print("========================")
        print("Testing provider fallback when GPS (gpsd) is not available...")
        print("")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  // Should prefer GPS
        locationManager.distanceFilter = kCLDistanceFilterNone    // Get all updates
        
        locationManager.requestWhenInUseAuthorization()
        
        // Test one-time location request
        print("1. Testing requestLocation() with kCLLocationAccuracyBest (should try GPS first)...")
        locationManager.requestLocation()
        
        // Give it some time then test continuous updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { @MainActor in
            if !self.testCompleted {
                print("")
                print("2. Testing startUpdatingLocation() with continuous updates...")
                self.locationManager.startUpdatingLocation()
                
                // Stop after a few updates
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { @MainActor in
                    self.locationManager.stopUpdatingLocation()
                    print("")
                    print("✅ Test completed! Provider fallback is working if you see location updates above.")
                    exit(0)
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔐 Authorization status: \(authorizationStatusString(status))")
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("📍 SUCCESS: Received location update")
        print("   Coordinate: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("   Accuracy: ±\(location.horizontalAccuracy)m")
        print("   Timestamp: \(location.timestamp)")
        
        // Determine likely provider based on accuracy
        let providerGuess: String
        if location.horizontalAccuracy <= 10 {
            providerGuess = "GPS (high accuracy)"
        } else if location.horizontalAccuracy <= 100 {
            providerGuess = "WiFi (medium accuracy)"
        } else {
            providerGuess = "IP Geolocation (low accuracy)"
        }
        print("   Likely Provider: \(providerGuess)")
        print("")
        
        Task { @MainActor in
            testCompleted = true
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        
        // Check if this is a GPS-specific error
        if error.localizedDescription.contains("gpsd") {
            print("   This is expected - GPS daemon is not available")
            print("   Fallback providers should be tried automatically...")
        }
        print("")
    }
    
    nonisolated private func authorizationStatusString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted" 
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Main Entry Point

@main
struct ProviderFallbackMain {
    static func main() {
        let test = ProviderFallbackTest()
        test.runTest()
        
        // Keep running
        RunLoop.current.run()
    }
}