import Foundation
import OpenCoreLocation

/// Example demonstrating the new location accuracy providers
class LocationAccuracyExample {
    
    func demonstrateProviders() async {
        print("=== OpenCoreLocation Accuracy Providers Demo ===\n")
        
        // Create location manager
        let locationManager = CLLocationManager()
        let delegate = ExampleDelegate()
        locationManager.delegate = delegate
        
        // Test different accuracy levels
        let accuracies: [(CLLocationAccuracy, String)] = [
            (kCLLocationAccuracyBestForNavigation, "Best for Navigation (GPS)"),
            (kCLLocationAccuracyBest, "Best (GPS)"),
            (kCLLocationAccuracyNearestTenMeters, "10m accuracy (GPS)"),
            (kCLLocationAccuracyHundredMeters, "100m accuracy (WiFi)"),
            (kCLLocationAccuracyKilometer, "1km accuracy (IP)"),
            (kCLLocationAccuracyThreeKilometers, "3km accuracy (IP)")
        ]
        
        for (accuracy, description) in accuracies {
            print("Testing \(description)...")
            locationManager.desiredAccuracy = accuracy
            
            locationManager.requestLocation()
            
            // Wait a bit for the response
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            if let location = delegate.lastLocation {
                print("✅ Received location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                print("   Accuracy: \(location.horizontalAccuracy)m")
                print("   Provider: \(getProviderName(for: accuracy))")
            } else if let error = delegate.lastError {
                print("❌ Failed: \(error.localizedDescription)")
                print("   This is expected if \(getProviderName(for: accuracy)) is not available")
            }
            
            print("")
            delegate.reset()
        }
    }
    
    private func getProviderName(for accuracy: CLLocationAccuracy) -> String {
        switch accuracy {
        case kCLLocationAccuracyBestForNavigation, kCLLocationAccuracyBest, kCLLocationAccuracyNearestTenMeters:
            return "GPS (gpsd)"
        case kCLLocationAccuracyHundredMeters:
            return "WiFi positioning"
        case kCLLocationAccuracyKilometer, kCLLocationAccuracyThreeKilometers:
            return "IP geolocation"
        default:
            return "Unknown"
        }
    }
}

class ExampleDelegate: NSObject, CLLocationManagerDelegate {
    var lastLocation: CLLocation?
    var lastError: Error?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastError = error
    }
    
    func reset() {
        lastLocation = nil
        lastError = nil
    }
}

// Usage:
// let example = LocationAccuracyExample()
// await example.demonstrateProviders()