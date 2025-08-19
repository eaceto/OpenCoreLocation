import Foundation
import OpenCoreLocation

/// Example demonstrating background location updates and automatic pausing
/// This shows how to configure CLLocationManager for efficient background tracking
@MainActor
class BackgroundLocationExample: CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var updateCount = 0
    private var lastLocation: CLLocation?
    private let startTime = Date()
    
    func runExample() {
        print("🌍 Background Location Updates Example")
        print("=====================================")
        print("This example demonstrates:")
        print("• Background location updates with reduced frequency")
        print("• Automatic pausing when device is stationary")
        print("• Adaptive update intervals based on movement")
        print("")
        
        // Configure location manager
        locationManager.delegate = self
        
        // Enable background location updates
        locationManager.allowsBackgroundLocationUpdates = true
        print("✅ Background location updates: ENABLED")
        print("   • Updates will continue with reduced frequency (30s intervals)")
        print("")
        
        // Enable automatic pausing
        locationManager.pausesLocationUpdatesAutomatically = true
        print("✅ Automatic pausing: ENABLED")
        print("   • Updates will pause after 60s of stationary behavior")
        print("   • Updates resume automatically when movement is detected")
        print("")
        
        // Set desired accuracy (will use WiFi/IP providers in background for efficiency)
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 50.0 // Only report significant movements
        
        print("📍 Configuration:")
        print("   • Accuracy: ±100 meters (WiFi-based)")
        print("   • Distance filter: 50 meters")
        print("")
        
        // Request authorization
        locationManager.requestAlwaysAuthorization()
        
        // Start location updates
        print("🚀 Starting background location updates...")
        print("   • Foreground interval: 1 second")
        print("   • Background interval: 30 seconds")
        print("   • Stationary interval: 60 seconds")
        print("")
        print("⏱️  Running for 2 minutes to demonstrate different modes...")
        print("")
        
        locationManager.startUpdatingLocation()
        
        // Simulate background mode after 30 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            print("")
            print("📱 Simulating app entering background mode...")
            print("   Updates will now occur every 30 seconds")
            print("")
        }
        
        // Stop after 2 minutes
        DispatchQueue.main.asyncAfter(deadline: .now() + 120.0) {
            self.stopExample()
        }
    }
    
    private func stopExample() {
        locationManager.stopUpdatingLocation()
        
        let duration = Date().timeIntervalSince(startTime)
        print("")
        print("📊 Summary:")
        print("   • Total duration: \(Int(duration)) seconds")
        print("   • Updates received: \(updateCount)")
        print("   • Average interval: \(String(format: "%.1f", duration/Double(max(updateCount, 1)))) seconds")
        
        if let location = lastLocation {
            print("   • Last location: (\(location.coordinate.latitude), \(location.coordinate.longitude))")
            print("   • Last accuracy: ±\(location.horizontalAccuracy)m")
        }
        
        print("")
        print("✅ Example completed!")
        print("")
        print("💡 Tips for production use:")
        print("   • Enable background modes in your app's capabilities")
        print("   • Handle app lifecycle transitions appropriately")
        print("   • Consider battery impact vs accuracy requirements")
        print("   • Use distance filter to reduce unnecessary updates")
        print("   • Monitor significant location changes for very low power tracking")
        
        exit(0)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Capture all needed values before entering Task
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let accuracy = location.horizontalAccuracy
        let timestamp = location.timestamp
        
        Task { @MainActor in
            updateCount += 1
            let elapsed = Date().timeIntervalSince(startTime)
            
            // Calculate distance moved since last update
            var distanceMoved: Double = 0
            if let last = lastLocation {
                distanceMoved = CLLocationUtils.calculateDistance(
                    from: (latitude: last.coordinate.latitude, longitude: last.coordinate.longitude),
                    to: (latitude: latitude, longitude: longitude)
                )
            }
            
            print("📍 Update #\(updateCount) at \(String(format: "%.0f", elapsed))s:")
            print("   • Location: (\(String(format: "%.4f", latitude)), \(String(format: "%.4f", longitude)))")
            print("   • Accuracy: ±\(accuracy)m")
            
            if distanceMoved > 0 {
                print("   • Distance moved: \(String(format: "%.1f", distanceMoved))m")
            }
            
            // Detect update interval pattern
            if updateCount > 1 {
                let avgInterval = elapsed / Double(updateCount - 1)
                if avgInterval > 45 {
                    print("   • Mode: STATIONARY (60s interval)")
                } else if avgInterval > 20 {
                    print("   • Mode: BACKGROUND (30s interval)")
                } else {
                    print("   • Mode: FOREGROUND (1s interval)")
                }
            }
            
            // Create new location with captured values for storage
            lastLocation = CLLocation(
                latitude: latitude,
                longitude: longitude
            )
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔐 Authorization status: \(status)")
        if status == .denied || status == .restricted {
            print("⚠️  Location access denied. Background updates will not work.")
            Task { @MainActor in
                stopExample()
            }
        }
    }
}

// MARK: - Main Entry Point

@main
struct BackgroundLocationMain {
    static func main() {
        let example = BackgroundLocationExample()
        example.runExample()
        
        // Keep running for the example duration
        RunLoop.current.run()
    }
}