import Foundation
@testable import OpenCoreLocation

// MARK: - Mock Delegate
class MockLocationManagerDelegate: CLLocationManagerDelegate {
    var didChangeAuthorizationStatus: CLAuthorizationStatus?
    var didUpdateLocations: [CLLocation] = []
    var didFailWithError: Error?
    var didUpdateHeading: CLHeading?
    var didChangeAccuracyAuthorization: CLAccuracyAuthorization?

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorizationStatus = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocations = locations
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailWithError = error
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        didUpdateHeading = newHeading
    }

    func locationManager(_ manager: CLLocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        didChangeAccuracyAuthorization = accuracyAuthorization
    }
}
