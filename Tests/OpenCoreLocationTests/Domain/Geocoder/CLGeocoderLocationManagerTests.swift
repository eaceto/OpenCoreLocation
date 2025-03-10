import XCTest

@testable import OpenCoreLocation

// MARK: - CLLocationManager Delegate for Testing
class CLLocationManagerTestDelegate: NSObject, CLLocationManagerDelegate {
    private var locationContinuation: CheckedContinuation<[CLLocation], Error>?

    /// Asynchronously waits for a location update.
    func waitForLocationUpdate() async throws -> [CLLocation] {
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationContinuation?.resume(returning: locations)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}

// MARK: - CLGeocoder + CLLocationManager Tests
final class CLGeocoderLocationManagerTests: XCTestCase {
    var locationManager: CLLocationManager!
    var locationDelegate: CLLocationManagerTestDelegate!
    var geocoder: CLGeocoder!

    override func setUp() {
        super.setUp()
        locationManager = CLLocationManager()
        locationDelegate = CLLocationManagerTestDelegate()
        locationManager.delegate = locationDelegate
        geocoder = CLGeocoder()
    }

    override func tearDown() {
        locationManager.stopUpdatingLocation()
        locationManager = nil
        locationDelegate = nil
        geocoder = nil
        super.tearDown()
    }

    // MARK: - Test Geocode Address String (Async/Await)
    func testGeocodeAddressString() async throws {
        let testAddress = "1600 Amphitheatre Parkway, Mountain View, CA"

        let placemarks = try await geocoder.geocodeAddressString(testAddress)

        XCTAssertFalse(placemarks.isEmpty, "Placemarks should not be empty.")

        let firstPlacemark = placemarks.first!
        XCTAssertNotNil(firstPlacemark.location, "Placemark should contain a valid location.")
        XCTAssertNotEqual(firstPlacemark.location?.coordinate.latitude, 0.0, "Latitude should not be 0.0")
        XCTAssertNotEqual(firstPlacemark.location?.coordinate.longitude, 0.0, "Longitude should not be 0.0")
    }

    // MARK: - Test Reverse Geocode from Location Manager (Async/Await)
    func testReverseGeocodeFromLocationManager() async throws {
        // Request authorization
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        // Wait for location update
        let locations = try await locationDelegate.waitForLocationUpdate()
        XCTAssertFalse(locations.isEmpty, "Expected at least one location update.")

        // Perform reverse geocoding
        let placemarks = try await geocoder.reverseGeocodeLocation(locations.first!)
        XCTAssertFalse(placemarks.isEmpty, "Placemarks should not be empty.")

        if let placemark = placemarks.first {
            debugPrint("Received Address: \(placemark.name ?? "Unknown Address")")
        }
    }
}
