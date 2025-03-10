import XCTest

@testable import OpenCoreLocation
// import CoreLocation

// MARK: - CLLocationManagerTests
final class CLLocationManagerInitializeTests: XCTestCase {
    var locationManager: CLLocationManager!
    var mockDelegate: MockLocationManagerDelegate!

    override func setUp() {
        super.setUp()
        locationManager = CLLocationManager()
    }

    override func tearDown() {
        locationManager = nil
        mockDelegate = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests
    func testInitialization() {
        XCTAssertNil(locationManager.delegate, "Delegate should be nil upon initialization.")
        XCTAssertEqual(locationManager.authorizationStatus, .notDetermined, "Default authorization status should be .notDetermined.")
        XCTAssertEqual(locationManager.accuracyAuthorization, .fullAccuracy, "Default accuracy authorization should be .fullAccuracy.")
        XCTAssertEqual(locationManager.activityType, .other, "Default activity type should be .other.")
        XCTAssertEqual(locationManager.distanceFilter, 10.0, "Default distance filter should be 10 meters.")
        XCTAssertEqual(locationManager.desiredAccuracy, kCLLocationAccuracyBest, "Default desired accuracy should be .best.")
        XCTAssertFalse(locationManager.pausesLocationUpdatesAutomatically, "Location updates should not pause automatically by default.")
        XCTAssertFalse(locationManager.allowsBackgroundLocationUpdates, "Background location updates should not be allowed by default.")
    }
}
