import Foundation
import OpenCoreLocation

/// Simple test to verify IP geolocation provider works
class SimpleIPTest: CLLocationManagerDelegate {
    private var locationReceived = false
    
    func runTest() async {
        print("🌐 Simple IP Geolocation Test")
        print("============================")
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer  // Should use IP provider
        
        print("Testing IP geolocation with kCLLocationAccuracyKilometer...")
        print("This should use the IP geolocation provider...")
        
        // Request location
        locationManager.requestLocation()
        
        // Wait for response with timeout
        let startTime = Date()
        while !locationReceived && Date().timeIntervalSince(startTime) < 10.0 {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        if !locationReceived {
            print("⏰ Test timed out - no location received after 10 seconds")
            print("   This could indicate network issues or provider failure")
        }
        
        print("✅ Test completed")
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationReceived = true
        
        print("✅ SUCCESS: Received IP-based location!")
        print("   Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("   Accuracy: ±\(location.horizontalAccuracy)m")
        print("   Timestamp: \(location.timestamp)")
        
        // Verify this is likely IP-based (accuracy > 1000m typically)
        if location.horizontalAccuracy > 1000 {
            print("   ✅ Accuracy indicates IP geolocation provider was used")
        } else {
            print("   ⚠️  High accuracy (\(location.horizontalAccuracy)m) - might be WiFi fallback")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationReceived = true
        print("❌ Location request failed: \(error.localizedDescription)")
        if error.localizedDescription.contains("gpsd") {
            print("   This GPS error is expected - should fallback to IP provider")
        }
    }
}

@main
struct SimpleIPMain {
    static func main() async {
        let test = SimpleIPTest()
        await test.runTest()
    }
}