# OpenCoreLocation

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-blue.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

OpenCoreLocation is a comprehensive Swift package that brings Apple's **CoreLocation** functionality to **Linux** while maintaining full API compatibility. This library enables seamless cross-platform development by providing the same CoreLocation APIs you know and love on Linux systems.

## 🚀 Key Features

### 📍 **Multi-Provider Location System**
- **GPS Provider**: High-accuracy positioning via gpsd integration (1-10m accuracy)
- **WiFi Provider**: Medium-accuracy positioning using WiFi access points (40m+ accuracy)  
- **IP Provider**: Low-accuracy geolocation via IP address (1km+ accuracy)
- **Intelligent Fallback**: Automatically selects best available provider based on desired accuracy

### 🎯 **Advanced Location Management**
- **Distance Filter**: Only report location updates when device moves beyond specified threshold
- **Accuracy-Based Selection**: Automatic provider selection based on `CLLocationAccuracy` constants
- **Thread-Safe Implementation**: Concurrent queue-based architecture for optimal performance
- **Smart Caching**: Reduces redundant API calls and improves battery life

### 🔍 **Region Monitoring & Geofencing**
- **Circular Regions**: Monitor entry/exit events for geographic areas
- **Software Geofencing**: Real-time boundary detection without hardware dependencies
- **Selective Notifications**: Configure entry-only, exit-only, or both event types
- **Multiple Region Support**: Monitor multiple regions simultaneously
- **Background Monitoring**: Automatic region checking with location updates

### 🌍 **Comprehensive Geographic Utilities**
- **CLLocationUtils**: Centralized geographic calculations and utilities
- **Distance Calculations**: Accurate great-circle distance using haversine formula
- **Bearing Calculations**: Compass direction between coordinate points
- **Coordinate Validation**: Input validation for latitude/longitude ranges

### 📮 **Geocoding Services**
- **Forward Geocoding**: Address → Coordinates using OpenStreetMap
- **Reverse Geocoding**: Coordinates → Address information
- **Async/Await Support**: Modern Swift concurrency patterns

## 🏗️ Project Status

OpenCoreLocation is production-ready with comprehensive testing and documentation. The library provides a robust, feature-complete implementation of CoreLocation APIs for Linux systems.

### 🆕 Recent Updates (v1.1.0)
- **✅ Real-time Region Monitoring**: Complete geofencing implementation with entry/exit callbacks
- **✅ Enhanced Documentation**: Full API documentation with GitHub Pages deployment
- **✅ Development Tools**: Makefile, automated testing, and CI/CD integration
- **✅ Improved Testing**: 50+ test cases covering all major functionality
- **✅ Geographic Utilities**: Centralized `CLLocationUtils` with distance/bearing calculations
- **✅ Multi-provider Architecture**: Intelligent fallback system for GPS, WiFi, and IP providers

### ✅ Implemented Features
- [x] **Core Location APIs**: `CLLocationManager`, `CLLocationManagerDelegate`, `CLLocation`
- [x] **Geocoding**: `CLGeocoder` with OpenStreetMap integration  
- [x] **Region Monitoring**: `CLRegion`, `CLCircularRegion` with real-time geofencing
- [x] **Multi-Provider System**: GPS, WiFi, and IP-based location providers
- [x] **Distance Filtering**: Intelligent location update filtering
- [x] **Geographic Utilities**: `CLLocationUtils` with distance/bearing calculations
- [x] **Cross-Platform**: Support for Linux, macOS, iOS, tvOS, and watchOS
- [x] **Comprehensive Testing**: 50+ test cases with >90% code coverage
- [x] **Region Geofencing**: Entry/exit detection with delegate callbacks
- [x] **Documentation System**: Complete API documentation with Jazzy integration

### 🚧 Future Enhancements
- [ ] **Visit Detection**: `CLVisit` for detecting significant locations
- [ ] **Beacon Ranging**: iBeacon support for proximity detection
- [ ] **Background Updates**: Persistent location tracking capabilities
- [ ] **Region Monitoring on GPS Loss**: Fallback strategies for provider failures

## 📦 Installation

### Swift Package Manager

Add OpenCoreLocation to your project using Swift Package Manager:

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "YourProject",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    dependencies: [
        .package(url: "https://github.com/eaceto/OpenCoreLocation.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourProject",
            dependencies: ["OpenCoreLocation"]
        )
    ]
)
```

### Xcode Integration
1. Open your Xcode project
2. Go to **File > Add Package Dependencies**  
3. Enter: `https://github.com/eaceto/OpenCoreLocation.git`
4. Select the latest version

## 🛠️ System Requirements

### Linux GPS Support (Optional)
For high-accuracy GPS positioning on Linux:

```bash
# Install GPS daemon
sudo apt-get update
sudo apt-get install gpsd gpsd-clients

# Start GPS service
sudo systemctl start gpsd
sudo systemctl enable gpsd
```

### WiFi Positioning (Optional)
WiFi-based positioning uses NetworkManager (usually pre-installed):

```bash
# Ensure NetworkManager is available
sudo apt-get install network-manager
```

> **Note**: OpenCoreLocation works without GPS or WiFi by falling back to IP-based geolocation

## 📖 Usage

### Basic Location Tracking

```swift
#if os(Linux)
import OpenCoreLocation
#else
import CoreLocation
#endif

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("📍 Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("🎯 Accuracy: \(location.horizontalAccuracy)m")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }
}

// Create and configure location manager
let locationManager = CLLocationManager()
let delegate = LocationManagerDelegate()

locationManager.delegate = delegate
locationManager.desiredAccuracy = kCLLocationAccuracyBest
locationManager.distanceFilter = 10.0  // Only update if moved >10 meters

// Request authorization and start updates
locationManager.requestWhenInUseAuthorization()
locationManager.startUpdatingLocation()
```

### Advanced Accuracy Control

```swift
// High-accuracy GPS tracking (1-5m accuracy)
locationManager.desiredAccuracy = kCLLocationAccuracyBest

// Medium-accuracy WiFi positioning (20-100m accuracy)  
locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

// Low-accuracy IP geolocation (1-5km accuracy)
locationManager.desiredAccuracy = kCLLocationAccuracyKilometer

// Disable distance filtering for all updates
locationManager.distanceFilter = kCLDistanceFilterNone
```

### Geocoding

```swift
import OpenCoreLocation

let geocoder = CLGeocoder()

// Forward geocoding (Address → Coordinates)
let placemarks = try await geocoder.geocodeAddressString("1 Apple Park Way, Cupertino, CA")
if let location = placemarks.first?.location {
    print("📍 Apple Park: \(location.coordinate)")
}

// Reverse geocoding (Coordinates → Address)
let location = CLLocation(latitude: 37.3317, longitude: -122.0302)
let reverseResults = try await geocoder.reverseGeocodeLocation(location)
if let placemark = reverseResults.first {
    print("📮 Address: \(placemark.name ?? "Unknown")")
}
```

### Geographic Utilities

```swift
import OpenCoreLocation

// Distance calculations
let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
let newYork = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

let distance = CLLocationUtils.calculateDistance(from: sanFrancisco, to: newYork)
print("🌍 SF to NYC: \(distance/1000) km")

// Using extensions
let distanceExt = sanFrancisco.distance(to: newYork)
let bearing = sanFrancisco.bearing(to: newYork)
print("🧭 Bearing: \(bearing)° (roughly East)")

// Coordinate validation
let isValid = CLLocationUtils.isValidCoordinate(latitude: 37.7749, longitude: -122.4194)
print("✅ Valid coordinates: \(isValid)")
```

### Region Monitoring & Geofencing

#### Basic Region Setup
```swift
// Create circular region for monitoring
let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco
let region = CLCircularRegion(center: center, radius: 500.0, identifier: "downtown-sf")

// Configure notifications
region.notifyOnEntry = true   // Get notified when entering region
region.notifyOnExit = true    // Get notified when exiting region

// Test coordinate containment
let testPoint = CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4195)
let isInside = region.contains(testPoint)
print("📍 Point inside region: \(isInside)")
```

#### Real-time Geofencing
```swift
extension LocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("🎯 Entered region: \(region.identifier)")
        // Trigger entry actions (notifications, data sync, etc.)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("🚪 Exited region: \(region.identifier)")  
        // Trigger exit actions (cleanup, notifications, etc.)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            print("📍 Currently inside: \(region.identifier)")
        case .outside:
            print("🌍 Currently outside: \(region.identifier)")
        case .unknown:
            print("❓ Region state unknown: \(region.identifier)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("👀 Started monitoring: \(region.identifier)")
        // Request initial state
        manager.requestState(for: region)
    }
}

// Start monitoring regions
locationManager.startMonitoring(for: region)

// Query current region state
locationManager.requestState(for: region)

// Stop monitoring when done
locationManager.stopMonitoring(for: region)
```

#### Multiple Region Management
```swift
// Monitor multiple regions simultaneously
let regions = [
    CLCircularRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), 
                    radius: 500.0, identifier: "downtown-sf"),
    CLCircularRegion(center: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094), 
                    radius: 200.0, identifier: "office"),
    CLCircularRegion(center: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4394), 
                    radius: 100.0, identifier: "home")
]

regions.forEach { region in
    region.notifyOnEntry = true
    region.notifyOnExit = true
    locationManager.startMonitoring(for: region)
}

print("📍 Monitoring \(locationManager.monitoredRegions.count) regions")
```

## 📊 Accuracy Comparison

| Provider | Accuracy | Update Interval | Use Case | Linux Requirements |
|----------|----------|----------------|----------|-------------------|
| **GPS** | 1-10m | 1 second | Navigation, fitness tracking, precise geofencing | gpsd + GPS hardware |
| **WiFi** | 20-100m | 30 seconds | General location services, urban geofencing | WiFi networks |
| **IP** | 500m-5km | 30 seconds | Regional services, weather, city-level geofencing | Internet connection |

### Geofencing Capabilities
- **Region Radius**: 10m - 100km (software-configurable)
- **Entry/Exit Detection**: Real-time boundary crossing detection
- **Multiple Regions**: Monitor up to 20 regions simultaneously  
- **Background Monitoring**: Automatic checking with location updates
- **Accuracy**: Depends on underlying location provider (GPS: ±5m, WiFi: ±50m, IP: ±1km)

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Run all tests
swift test

# Run specific test suites
swift test --filter CLLocationManagerTests
swift test --filter CLLocationUtilsTests
swift test --filter CLCircularRegionTests
swift test --filter CLLocationManagerRegionMonitoringTests

# Run with verbose output
swift test --verbose
```

## 📚 Documentation

### API Documentation
Comprehensive API documentation is available in the `/docs` directory, generated using Jazzy:

```bash
# Generate documentation locally
make docs

# Or use the build script directly  
./scripts/generate-docs.sh

# View documentation
open docs/index.html
```

**Online Documentation**: [https://eaceto.github.io/OpenCoreLocation](https://eaceto.github.io/OpenCoreLocation)

### Example Projects
Check the `/Examples` directory for complete demonstration code:

- **`LocationAccuracyExample.swift`**: Multi-provider accuracy system demonstration
- **`DistanceFilterDemo.swift`**: Distance filtering and battery optimization examples  
- **`LocationUtilsDemo.swift`**: Geographic utilities and calculations showcase
- **`RegionMonitoringExample.swift`**: Complete geofencing implementation with entry/exit detection

#### Running Examples
```bash
# Copy example to your project or run with Swift
swift Examples/RegionMonitoringExample.swift

# Or integrate into your existing project
cp Examples/RegionMonitoringExample.swift Sources/YourApp/
```

## 🔄 Cross-Platform Usage

OpenCoreLocation maintains full API compatibility with Apple's CoreLocation:

```swift
// Same code works on all platforms
#if os(Linux)
import OpenCoreLocation
#else
import CoreLocation
#endif

// Identical API usage across platforms
let manager = CLLocationManager()
manager.desiredAccuracy = kCLLocationAccuracyBest
manager.startUpdatingLocation()
```

## 🤝 Contributing

Contributions are welcome! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
```bash
git clone https://github.com/eaceto/OpenCoreLocation.git
cd OpenCoreLocation

# Build and test
swift build
swift test

# Use convenient make commands
make help          # Show all available commands
make build         # Build the project
make test          # Run tests
make docs          # Generate documentation
make clean         # Clean build artifacts
make dev           # Full development workflow
```

### Development Tools
The project includes several convenient development tools:

- **Makefile**: Convenient build commands and development workflows
- **Documentation Generator**: Automated Jazzy documentation with GitHub Pages deployment  
- **GitHub Actions**: Automated testing and documentation deployment
- **Test Coverage**: Comprehensive test suite with >90% code coverage
- **Code Quality**: Integrated linting and formatting tools

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by Apple's CoreLocation framework
- Uses OpenStreetMap for geocoding services
- Built with Swift's modern concurrency features

---

**Developed by [Ezequiel (Kimi) Aceto](https://eaceto.dev)**

*Making CoreLocation truly cross-platform* 🌍