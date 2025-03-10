//
//  main.swift
//  Core Location CLI (Linux Compatible)
//
//  Created by William Entriken, Adapted for Linux by OpenCoreLocation Team
//

import Foundation
import OpenCoreLocation

#if os(Linux)
import Dispatch
#endif

enum OutputFormat {
    case json
    case string(String)
}

class Delegate: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var follow = false
    var verbose = false
    var format = OutputFormat.string("%latitude %longitude")
    var timeoutTimer: Timer?
    var requiresPlacemarkLookup = false

    func start() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2.0
        locationManager.delegate = self
        if verbose {
            print("locationServicesEnabled: \(CLLocationManager.locationServicesEnabled())")
            print("significantLocationChangeMonitoringAvailable: \(CLLocationManager.significantLocationChangeMonitoringAvailable())")
            print("headingAvailable: \(CLLocationManager.headingAvailable())")
            print("regionMonitoringAvailable for CLRegion: \(CLLocationManager.isMonitoringAvailable(for: CLRegion.self))")
        }

        #if os(macOS)
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: {_ in self.timeout()})
        #else
        DispatchQueue.global().asyncAfter(deadline: .now() + 10.0) { self.timeout() }
        #endif

        self.locationManager.startUpdatingLocation()
    }

    func timeout() {
        print("Fetching location timed out. Exiting.")
        exit(1)
    }

    func printFormattedLocation(location: CLLocation, placemark: CLPlacemark? = nil) {
        var formattedPostalAddress: String?
        if let postalAddress = placemark?.postalAddress {
            formattedPostalAddress = "\(postalAddress.street),\(postalAddress.city),\(postalAddress.country)"
        }

        // Attempt to infer timezone for timestamp string
        var locatedTime: String?
        if let locatedTimeZone = placemark?.timeZone {
            let time = location.timestamp
            let formatter = DateFormatter()
            formatter.timeZone = locatedTimeZone
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            locatedTime = formatter.string(from: time)
        }

        let formattedParts: [String: String?] = [
            "latitude": String(format: "%0.6f", location.coordinate.latitude),
            "longitude": String(format: "%0.6f", location.coordinate.longitude),
            "altitude": String(format: "%0.2f", location.altitude),
            "direction": "\(location.course)",
            "speed": "\(Int(location.speed))",
            "h_accuracy": "\(Int(location.horizontalAccuracy))",
            "v_accuracy": "\(Int(location.verticalAccuracy))",
            "time": location.timestamp.description,

            // Placemark
            "name": placemark?.name,
            "isoCountryCode": placemark?.isoCountryCode,
            "country": placemark?.country,
            "postalCode": placemark?.postalCode,
            "administrativeArea": placemark?.administrativeArea,
            "subAdministrativeArea": placemark?.subAdministrativeArea,
            "locality": placemark?.locality,
            "subLocality": placemark?.subLocality,
            "thoroughfare": placemark?.thoroughfare,
            "subThoroughfare": placemark?.subThoroughfare,
            "region": placemark?.region?.identifier,
            "timeZone": placemark?.timeZone?.identifier,
            "time_local": locatedTime,

            // Address
            "address": formattedPostalAddress
        ]

        switch format {
        case .json:
            let output = try! JSONEncoder().encode(formattedParts)
            print(String(data: output, encoding: .utf8)!)
        case .string(let output):
            print(formattedParts.reduce(output, { partialResult, keyValuePair in
                partialResult.replacingOccurrences(of: "%\(keyValuePair.key)", with: keyValuePair.value ?? "")
            }))
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if self.verbose {
            print("Location authorization status: \(manager.authorizationStatus)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        timeoutTimer?.invalidate()
        let location = locations.first!
        if requiresPlacemarkLookup {
            self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error != nil {
                    print("Reverse geocode failed: \(error?.localizedDescription ?? "unknown error")")
                    exit(1)
                }
                let placemark = placemarks?.first
                self.printFormattedLocation(location: location, placemark: placemark)
                if !self.follow {
                    exit(0)
                }
            })
        } else {
            printFormattedLocation(location: location)
            if !self.follow {
                exit(0)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if error._code == 1 {
            print("CoreLocationCLI: ❌ Location services are disabled or location access denied.")
            exit(1)
        }
        print("CoreLocationCLI: ❌ \(error.localizedDescription)")
        exit(1)
    }
}

// MARK: - CLI Argument Parsing
let delegate = Delegate()
for (i, argument) in CommandLine.arguments.enumerated() {
    switch argument {
    case "-h", "--help":
        print("<help>")
        exit(0)
    case "-w", "--watch":
        delegate.follow = true
    case "-v", "--verbose":
        delegate.verbose = true
    case "-f", "--format":
        if CommandLine.arguments.count > i+1 {
            delegate.format = .string(CommandLine.arguments[i+1])
            let placemarkStrings = ["%address", "%name", "%isoCountryCode", "%country", "%postalCode", "%administrativeArea", "%subAdministrativeArea", "%locality", "%subLocality", "%thoroughfare", "%subThoroughfare", "%region", "%timeZone", "%time_local"]
            if placemarkStrings.contains(where: CommandLine.arguments[i+1].contains) {
                delegate.requiresPlacemarkLookup = true
            }
        }
    case "-j", "--json":
        delegate.format = .json
        delegate.requiresPlacemarkLookup = true
    default:
        break
    }
}

// Start the process
delegate.start()

// MARK: - Keep the Process Running
#if os(macOS)
RunLoop.main.run()
#else
dispatchMain() // Keeps the main thread alive on Linux
#endif
