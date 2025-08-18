import Foundation
import OpenCoreLocation

/// Example demonstrating distance filter functionality
class DistanceFilterDemo {
    
    func demonstrateDistanceFilter() async {
        print("=== Distance Filter Demo ===\n")
        
        let locationManager = CLLocationManager()
        let delegate = DemoDelegate()
        locationManager.delegate = delegate
        
        print("1. Testing with no distance filter (receive all updates):")
        locationManager.distanceFilter = kCLDistanceFilterNone
        print("   Distance filter: \(locationManager.distanceFilter) (disabled)")
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        
        let noFilterCount = delegate.locationCount
        print("   Received \(noFilterCount) location updates\n")
        
        locationManager.stopUpdatingLocation()
        delegate.reset()
        
        print("2. Testing with 100m distance filter:")
        locationManager.distanceFilter = 100.0
        print("   Distance filter: \(locationManager.distanceFilter) meters")
        print("   (Will only report locations if device moves >100m)")
        
        locationManager.startUpdatingLocation()
        
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        
        let filteredCount = delegate.locationCount
        print("   Received \(filteredCount) location updates")
        
        if filteredCount <= noFilterCount {
            print("   ✅ Distance filter working - fewer updates received")
        } else {
            print("   ⚠️  Expected fewer updates with distance filter")
        }
        
        locationManager.stopUpdatingLocation()
        delegate.reset()
        
        print("\n3. Testing with very large distance filter (1km):")
        locationManager.distanceFilter = 1000.0
        print("   Distance filter: \(locationManager.distanceFilter) meters")
        
        locationManager.startUpdatingLocation()
        
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        
        let largeFilterCount = delegate.locationCount
        print("   Received \(largeFilterCount) location updates")
        
        locationManager.stopUpdatingLocation()
        
        print("\n=== Distance Filter Features ===")
        print("• kCLDistanceFilterNone (-1.0): Disables filtering")
        print("• Positive values: Minimum movement in meters to trigger update")
        print("• First location is always reported")
        print("• Uses haversine formula for accurate distance calculation")
        print("• Thread-safe implementation")
        print("• Resets when location updates are stopped/restarted")
    }
}

class DemoDelegate: NSObject, CLLocationManagerDelegate {
    private(set) var locationCount = 0
    private var lastLocation: CLLocation?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationCount += locations.count
        
        for location in locations {
            if let last = lastLocation {
                let distance = location.distance(from: last)
                print("     Location \(locationCount): (\(location.coordinate.latitude), \(location.coordinate.longitude))")
                print("     Distance from previous: \(String(format: "%.1f", distance))m")
            } else {
                print("     First location: (\(location.coordinate.latitude), \(location.coordinate.longitude))")
            }
            lastLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("     Location error: \(error.localizedDescription)")
    }
    
    func reset() {
        locationCount = 0
        lastLocation = nil
    }
}

// MARK: - Main Entry Point

@main
struct DistanceFilterMain {
    static func main() async {
        let demo = DistanceFilterDemo()
        await demo.demonstrateDistanceFilter()
    }
}