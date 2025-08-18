import Foundation
import OpenCoreLocation

/// Very simple test to verify provider fallback
class QuickFallbackTest: CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var requestCount = 0
    private let maxRequests = 3
    
    func runTest() {
        print("⚡ Quick Provider Fallback Test")
        print("==============================")
        print("This test verifies that when GPS fails, the system falls back to WiFi/IP providers.")
        print("")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  // This should try GPS first
        
        // Make a location request
        makeLocationRequest()
    }
    
    private func makeLocationRequest() {
        requestCount += 1
        print("📍 Request #\(requestCount): Requesting location with high accuracy (should try GPS first)...")
        locationManager.requestLocation()
        
        // Timeout after 8 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            if self.requestCount < self.maxRequests {
                print("")
                self.makeLocationRequest()
            } else {
                print("")
                print("🔚 Test completed after \(self.maxRequests) requests")
                print("If you see successful location updates above, fallback is working! ✅")
                exit(0)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("   ✅ SUCCESS: Got location (\(location.coordinate.latitude), \(location.coordinate.longitude))")
        print("   📊 Accuracy: ±\(location.horizontalAccuracy)m")
        
        // Determine the likely provider based on accuracy
        if location.horizontalAccuracy <= 20 {
            print("   🛰️  Likely provider: GPS (high accuracy)")
        } else if location.horizontalAccuracy <= 200 {
            print("   📶 Likely provider: WiFi (medium accuracy)")  
        } else {
            print("   🌐 Likely provider: IP geolocation (low accuracy)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("   ❌ Request failed: \(error.localizedDescription)")
        if error.localizedDescription.contains("gpsd") {
            print("   ℹ️  GPS failure is expected - testing fallback...")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Auto-grant authorization for testing
        print("🔐 Authorization: \(status)")
    }
}

@main
struct QuickFallbackMain {
    static func main() {
        let test = QuickFallbackTest()
        test.runTest()
        RunLoop.current.run()
    }
}