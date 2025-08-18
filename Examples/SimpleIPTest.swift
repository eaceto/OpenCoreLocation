import Foundation
import OpenCoreLocation

/// Simple test to verify IP geolocation provider works
class SimpleIPTest {
    func runTest() async {
        print("🌐 Simple IP Geolocation Test")
        print("============================")
        
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer  // Should use IP provider
        
        print("Testing IP geolocation with kCLLocationAccuracyKilometer...")
        
        do {
            // This should use IP provider since we're requesting low accuracy
            locationManager.requestLocation()
            
            // Wait for response
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            print("✅ Test completed - check delegate calls above")
        } catch {
            print("❌ Test error: \(error)")
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