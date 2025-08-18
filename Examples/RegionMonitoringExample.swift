import Foundation
import OpenCoreLocation

/// Demonstrates region monitoring functionality in OpenCoreLocation
/// This example shows how to monitor geographic regions and receive notifications
/// when entering or exiting defined areas.
class RegionMonitoringExample: CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    func runExample() {
        print("🏛️  Region Monitoring Example")
        print("============================")
        
        // Configure location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0 // Update every 10 meters
        
        // Check if region monitoring is available
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            print("✅ Region monitoring is available for CLCircularRegion")
        } else {
            print("❌ Region monitoring is not available")
            return
        }
        
        // Define regions of interest
        setupRegions()
        
        // Start location updates (required for region monitoring)
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        print("\n📍 Starting location updates and region monitoring...")
        print("Walk around to test region entry/exit notifications!")
        print("Press Ctrl+C to stop.\n")
    }
    
    private func setupRegions() {
        // Example: Monitor a circular region around San Francisco city center
        let sanFranciscoCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let sanFranciscoRegion = CLCircularRegion(
            center: sanFranciscoCenter,
            radius: 500.0, // 500 meters
            identifier: "downtown-sf"
        )
        sanFranciscoRegion.notifyOnEntry = true
        sanFranciscoRegion.notifyOnExit = true
        
        // Example: Monitor a region around a specific landmark (Golden Gate Park)
        let goldenGatePark = CLLocationCoordinate2D(latitude: 37.7694, longitude: -122.4862)
        let parkRegion = CLCircularRegion(
            center: goldenGatePark,
            radius: 200.0, // 200 meters
            identifier: "golden-gate-park"
        )
        parkRegion.notifyOnEntry = true
        parkRegion.notifyOnExit = false // Only notify on entry, not exit
        
        // Example: Monitor a smaller region (office building or home)
        let officeLocation = CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094)
        let officeRegion = CLCircularRegion(
            center: officeLocation,
            radius: 50.0, // 50 meters
            identifier: "office-building"
        )
        officeRegion.notifyOnEntry = true
        officeRegion.notifyOnExit = true
        
        // Start monitoring all regions
        locationManager.startMonitoring(for: sanFranciscoRegion)
        locationManager.startMonitoring(for: parkRegion)
        locationManager.startMonitoring(for: officeRegion)
        
        print("📍 Monitoring regions:")
        print("  • Downtown SF (500m radius) - Entry & Exit notifications")
        print("  • Golden Gate Park (200m radius) - Entry notifications only")
        print("  • Office Building (50m radius) - Entry & Exit notifications")
        print("  Total monitored regions: \\(locationManager.monitoredRegions.count)")
    }
    
    // MARK: - CLLocationManagerDelegate Implementation
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔐 Authorization status changed: \\(authorizationStatusString(status))")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location authorization granted")
        case .denied, .restricted:
            print("❌ Location authorization denied")
        case .notDetermined:
            print("⏳ Location authorization not determined")
        @unknown default:
            print("❓ Unknown authorization status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("📍 Location updated: (\\(location.coordinate.latitude), \\(location.coordinate.longitude)) ±\\(location.horizontalAccuracy)m")
        
        // Check the state of all monitored regions when location updates
        for region in manager.monitoredRegions {
            manager.requestState(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location manager error: \\(error.localizedDescription)")
    }
    
    // MARK: - Region Monitoring Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("🟢 Started monitoring region: \\(region.identifier)")
        // Request initial state of the region
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let regionName = regionDisplayName(for: region.identifier)
        print("🎯 ENTERED region: \\(regionName)")
        
        // You could trigger actions here like:
        // - Send a notification
        // - Log the event
        // - Update UI
        // - Start specific location tracking
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let regionName = regionDisplayName(for: region.identifier)
        print("🚪 EXITED region: \\(regionName)")
        
        // You could trigger actions here like:
        // - Send a farewell notification
        // - Stop specific services
        // - Update tracking state
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        let regionName = regionDisplayName(for: region.identifier)
        let stateString = regionStateString(state)
        print("🔍 Region state determined: \\(regionName) is \\(stateString)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        let regionName = region?.identifier ?? "unknown"
        print("❌ Region monitoring failed for \\(regionName): \\(error.localizedDescription)")
    }
    
    // MARK: - Helper Methods
    
    private func regionDisplayName(for identifier: String) -> String {
        switch identifier {
        case "downtown-sf":
            return "Downtown San Francisco"
        case "golden-gate-park":
            return "Golden Gate Park"
        case "office-building":
            return "Office Building"
        default:
            return identifier
        }
    }
    
    private func authorizationStatusString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Authorized Always"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        @unknown default:
            return "Unknown"
        }
    }
    
    private func regionStateString(_ state: CLRegionState) -> String {
        switch state {
        case .unknown:
            return "Unknown"
        case .inside:
            return "Inside"
        case .outside:
            return "Outside"
        }
    }
}

// MARK: - Usage Example

/// Run the region monitoring example
/// This demonstrates real-world usage of OpenCoreLocation's region monitoring capabilities
func runRegionMonitoringExample() {
    let example = RegionMonitoringExample()
    example.runExample()
    
    // Keep the example running
    RunLoop.current.run()
}