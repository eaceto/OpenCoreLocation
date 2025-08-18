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

### ✅ Implemented Features
- [x] **Core Location APIs**: `CLLocationManager`, `CLLocationManagerDelegate`, `CLLocation`
- [x] **Geocoding**: `CLGeocoder` with OpenStreetMap integration  
- [x] **Region Monitoring**: `CLRegion`, `CLCircularRegion` with accurate containment checks
- [x] **Multi-Provider System**: GPS, WiFi, and IP-based location providers
- [x] **Distance Filtering**: Intelligent location update filtering
- [x] **Geographic Utilities**: `CLLocationUtils` with distance/bearing calculations
- [x] **Cross-Platform**: Support for Linux, macOS, iOS, tvOS, and watchOS
- [x] **Comprehensive Testing**: 40+ test cases with >90% code coverage

### 🚧 Future Enhancements
- [ ] **Real-time Region Monitoring**: Active geofencing with delegate callbacks
- [ ] **Visit Detection**: `CLVisit` for detecting significant locations
- [ ] **Beacon Ranging**: iBeacon support for proximity detection
- [ ] **Background Updates**: Persistent location tracking capabilities

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

### Region Monitoring

```swift
// Create circular region
let applepark = CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0302)
let region = CLCircularRegion(center: applepark, radius: 1000, identifier: "Apple Park")

// Test if coordinate is inside region
let testCoordinate = CLLocationCoordinate2D(latitude: 37.3350, longitude: -122.0300)
let isInside = region.contains(testCoordinate)
print("📍 Inside Apple Park region: \(isInside)")
```

## 📊 Accuracy Comparison

| Provider | Accuracy | Update Interval | Use Case | Linux Requirements |
|----------|----------|----------------|----------|-------------------|
| **GPS** | 1-10m | 1 second | Navigation, fitness tracking | gpsd + GPS hardware |
| **WiFi** | 20-100m | 30 seconds | General location services | WiFi networks |
| **IP** | 500m-5km | 30 seconds | Regional services, weather | Internet connection |

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Run all tests
swift test

# Run specific test suites
swift test --filter CLLocationManagerTests
swift test --filter CLLocationUtilsTests
swift test --filter CLCircularRegionTests

# Run with verbose output
swift test --verbose
```

## 📚 Documentation

### API Documentation
Comprehensive API documentation is available in the `/docs` directory, generated using Jazzy:

```bash
# Generate documentation
jazzy --clean --build-tool-arguments -Xswiftc,-swift-version,-Xswiftc,5.7

# View documentation
open docs/index.html
```

### Example Projects
Check the `/Examples` directory for demonstration code:
- `LocationAccuracyExample.swift`: Multi-provider accuracy demonstration
- `DistanceFilterDemo.swift`: Distance filtering examples  
- `LocationUtilsDemo.swift`: Geographic utilities showcase

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
swift build
swift test
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by Apple's CoreLocation framework
- Uses OpenStreetMap for geocoding services
- Built with Swift's modern concurrency features

---

**Developed by [Ezequiel (Kimi) Aceto](https://eaceto.dev)**

*Making CoreLocation truly cross-platform* 🌍