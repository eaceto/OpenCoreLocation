import XCTest

@testable import OpenCoreLocation
// mport CoreLocation

final class CoreLocationCLITests: XCTestCase {

    private var locationManager: CLLocationManager!
    fileprivate var mockDelegate: BasicUsageLocationManagerDelegate!
    private var locationReceivedExpectation: XCTestExpectation!

    override func setUp() async throws {
        try await super.setUp()
        locationManager = CLLocationManager()
        mockDelegate = BasicUsageLocationManagerDelegate()
        locationManager.delegate = mockDelegate
    }

    override func tearDown() async throws {
        locationManager.stopUpdatingLocation()
        locationManager = nil
        mockDelegate = nil
        try await super.tearDown()
    }

    // MARK: - Location Fetch Test
    func testFetchLocation() async throws {
        locationReceivedExpectation = expectation(description: "Location should be received before timeout.")
        mockDelegate.locationReceivedExpectation = locationReceivedExpectation

        // Request location update
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Wait for a location to be received or timeout after 15 secs
        await fulfillment(of: [locationReceivedExpectation], timeout: 15.0)

        // Check the received location
        guard let location = mockDelegate.didUpdateLocations.first else {
            XCTFail("No location received.")
            return
        }

        XCTAssertGreaterThan(location.coordinate.latitude, -90.0, "Latitude should be greater than -90.0.")
        XCTAssertLessThan(location.coordinate.latitude, 90.0, "Latitude should be less than 90.0.")
        XCTAssertGreaterThan(location.coordinate.longitude, -180.0, "Longitude should be greater than -180.0.")
        XCTAssertLessThan(location.coordinate.longitude, 180.0, "Longitude should be less than 180.0.")
    }
}

// MARK: - Mock Delegate
private class BasicUsageLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var didUpdateLocations: [CLLocation] = []
    var locationReceivedExpectation: XCTestExpectation?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocations.append(contentsOf: locations)

        // Fulfill the expectation as soon as the location is received
        locationReceivedExpectation?.fulfill()
    }
}
