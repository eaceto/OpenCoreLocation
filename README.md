# OpenCoreLocation

OpenCoreLocation is a work-in-progress library with the goal of bringing Apple's **CoreLocation** functionality to **Linux**.

## Project Status
This project is currently under active development, aiming to create a fully compatible CoreLocation API for Linux environments. The implementation focuses on maintaining the same API and behavior as Apple's CoreLocation, making it easier to port applications to Linux.

## Roadmap
- [x] Implement CoreLocation enums and basic structures.
- [x] Implement `CLLocationManager` and `CLLocationManagerDelegate` classes.
- [x] Implement `CLGeocoder` class.
- [ ] Add support for more advanced location services (e.g., region monitoring, heading updates).
- [ ] Implement more accuracy-based providers for different use cases.
- [ ] Extensive testing and validation on Linux distributions.

## Installation

## Installation

### Using Swift Package Manager (SPM)

You can add **OpenCoreLocation** to your project using **Swift Package Manager (SPM)**.

#### Step 1: Add the Dependency

In your **Package.swift**, add the following dependency:

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "YourProject",
    platforms: [
        .macOS(.v10_15), .linux
    ],
    dependencies: [
        .package(url: "https://github.com/yourusername/OpenCoreLocation.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourProject",
            dependencies: ["OpenCoreLocation"]
        )
    ]
)
```

If you’re working in **Xcode**, you can also add OpenCoreLocation via Xcode’s SPM Integration:
1.	Open your Xcode Project.
2.	Go to **File > Swift Packages > Add Package Dependency**.
3.	Enter the repository URL: https://github.com/eaceto/OpenCoreLocation.git    


## Usage

To use **OpenCoreLocation**, import it in your Swift project. Since this library is intended to replace Apple's `CoreLocation` on **Linux**, you should conditionally import `CoreLocation` on macOS and iOS while using `OpenCoreLocation` on Linux.

### Basic Example

```swift
#if os(Linux)
import OpenCoreLocation
#else
import CoreLocation
#endif

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Updated location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
}

let locationManager = CLLocationManager()
let delegate = LocationManagerDelegate()

locationManager.delegate = delegate
locationManager.requestWhenInUseAuthorization()
locationManager.startUpdatingLocation()
````

**Notes:**
* On Linux, this will use OpenCoreLocation to provide similar functionality to CoreLocation on macOS.
* The #if os(Linux) condition ensures that the correct library is imported based on the operating system.
* The CLLocationManager instance works the same way as in Apple’s API, making it easy to port existing code.


## Running the Sample Application
A sample application using OpenCoreLocation is available in the `Applications/SampleApp` directory. This CLI tool fetches the current location and displays it in a formatted manner.

### **Prerequisites**
- Swift 5.7 (or newer) installed
- `swift` command available in the terminal
- Network access (for geocoding and location services)

### **Steps to Run**

1. Clone the repository:
```sh
git clone https://github.com/your-repo/OpenCoreLocation.git
cd OpenCoreLocation
```

2.	Navigate to the sample app directory:
```sh
cd Applications/SampleApp
```

3.	Build and run the sample application:
```sh
swift run
```

## Example Usage

By default, the sample app will print the latitude and longitude of the current location. You can modify the output format using the following flags:

```sh
swift run SampleApp -v              # Verbose mode (prints debugging info)
swift run SampleApp -j              # Output JSON format
swift run SampleApp -f "%latitude, %longitude"  # Custom format
swift run SampleApp -w              # Watch mode (continuously updates location)
```

### Expected output

```sh
40.4168, -3.7038  # Example output (Madrid, Puerta del Sol)
```

## Contributing
Contributions are welcome! Please reach out if you're interested in collaborating on this project.

## License
This project is licensed under the **MIT License**.

---
*Developed by [Ezequiel (Kimi) Aceto](https://eaceto.dev)*