import XCTest

@testable import OpenCoreLocation

// MARK: - CLLocationManagerTests
final class CLLocationManagerTests: XCTestCase {
    var locationManager: CLLocationManager!
    var mockDelegate: MockLocationManagerDelegate!

    override func setUp() {
        super.setUp()
        locationManager = CLLocationManager()
        mockDelegate = MockLocationManagerDelegate()
        locationManager.delegate = mockDelegate
    }

    override func tearDown() {
        locationManager = nil
        mockDelegate = nil
        super.tearDown()
    }

    // MARK: - Authorization Tests
    func testRequestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        XCTAssertEqual(locationManager.authorizationStatus, .authorizedWhenInUse)
        XCTAssertEqual(mockDelegate.didChangeAuthorizationStatus, .authorizedWhenInUse)
    }

    func testRequestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
        XCTAssertEqual(locationManager.authorizationStatus, .authorizedAlways)
        XCTAssertEqual(mockDelegate.didChangeAuthorizationStatus, .authorizedAlways)
    }

    // MARK: - Location Updates
    func testStartAndStopUpdatingLocation() async {
        locationManager.startUpdatingLocation()

        // Wait 10 seconds
        try? await Task.sleep(nanoseconds: 15 * 1_000_000_000)

        XCTAssertNotNil(locationManager.location)
        XCTAssertFalse(mockDelegate.didUpdateLocations.isEmpty)

        locationManager.stopUpdatingLocation()
        XCTAssertNil(locationManager.location)
    }

    // MARK: - Services Availability
    func testServicesAvailable() {
        XCTAssertTrue(CLLocationManager.locationServicesEnabled())
        XCTAssertFalse(CLLocationManager.headingAvailable())
        XCTAssertFalse(CLLocationManager.significantLocationChangeMonitoringAvailable())
        XCTAssertFalse(CLLocationManager.isMonitoringAvailable(for: CLRegion.self))
        XCTAssertFalse(CLLocationManager.isRangingAvailable())
    }

    // MARK: - Heading Updates
    func testStartUpdatingHeading() {
        locationManager.startUpdatingHeading()
        XCTAssertNil(mockDelegate.didUpdateHeading)
    }

    // MARK: - Accuracy Authorization
    @MainActor
    func testRequestTemporaryFullAccuracyAuthorization() async {
        let expectation = expectation(description: "Full accuracy requested")

        locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "TestPurpose") { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(mockDelegate.didChangeAccuracyAuthorization, .fullAccuracy)
    }
}
