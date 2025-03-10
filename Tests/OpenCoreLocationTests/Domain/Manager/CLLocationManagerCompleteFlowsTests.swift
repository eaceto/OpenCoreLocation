import XCTest

 @testable import OpenCoreLocation
// import CoreLocation

// MARK: - Mock Delegate
class MockCLLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var didChangeAuthorizationStatus: CLAuthorizationStatus?
    var didUpdateLocations: [CLLocation] = []
    var didFailWithError: Error?

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorizationStatus = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugPrint("Received locations \(locations)")
        didUpdateLocations.append(contentsOf: locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Received error: \(error)")
        didFailWithError = error
    }
}

// MARK: - CLLocationManager Complete Flows Tests
final class CLLocationManagerCompleteFlowsTests: XCTestCase {
    var locationManager: CLLocationManager!
    var mockDelegate: MockCLLocationManagerDelegate!

    override func setUp() {
        super.setUp()
        locationManager = CLLocationManager()
        mockDelegate = MockCLLocationManagerDelegate()
        locationManager.delegate = mockDelegate
    }

    override func tearDown() {
        locationManager = nil
        mockDelegate = nil
        super.tearDown()
    }

    // MARK: - Authorization and Location Update Test
    func testRequestAuthorizationAndReceiveLocation() async throws {
        let authExpectation = expectation(description: "Authorization status updated")
        let locationExpectation = expectation(description: "Received first location update")

        // Request authorization for "When in Use"
        locationManager.requestAlwaysAuthorization()

        // Wait for authorization change
        Task {
            while self.mockDelegate.didChangeAuthorizationStatus != .authorizedAlways {
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms sleep
            }
            authExpectation.fulfill()
        }

        await fulfillment(of: [authExpectation], timeout: 3.0)

        // Request location updates
        locationManager.startUpdatingLocation()

        // Wait for the first location update
        Task {
            while self.mockDelegate.didUpdateLocations.isEmpty {
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms sleep
            }
            locationExpectation.fulfill()
        }

        await fulfillment(of: [locationExpectation], timeout: 10.0)

        // Validate the received location
        XCTAssertFalse(mockDelegate.didUpdateLocations.isEmpty, "Expected at least one location update")
        XCTAssertNotNil(mockDelegate.didUpdateLocations.first, "Expected a valid location but got nil")
    }

    // MARK: - Test Receiving Two Location Updates
    func testReceiveSeveralLocationUpdates() async throws {
        let authExpectation = expectation(description: "Authorization status updated")
        let locationExpectation = expectation(description: "Received two location updates")

        // Request authorization
        locationManager.requestAlwaysAuthorization()

        // Wait for authorization change
        Task {
            while self.mockDelegate.didChangeAuthorizationStatus != .authorizedAlways {
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms sleep
            }
            authExpectation.fulfill()
        }

        await fulfillment(of: [authExpectation], timeout: 3.0)

        // Request location updates
        locationManager.startUpdatingLocation()

        let numberOfLocationUpdatesToExpect: Int = 3

        // Wait for two location updates
        Task {
            while self.mockDelegate.didUpdateLocations.count < numberOfLocationUpdatesToExpect {
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms sleep
            }
            locationExpectation.fulfill()
        }

        await fulfillment(of: [locationExpectation], timeout: 20.0 * Double((numberOfLocationUpdatesToExpect + 1)))

        // Validate that at least two location updates were received
        if mockDelegate.didUpdateLocations.count < numberOfLocationUpdatesToExpect {
            XCTFail("Expected at least two location updates")
            return
        }
        XCTAssertNotNil(mockDelegate.didUpdateLocations[0], "Expected a valid first location update but got nil")
        XCTAssertNotNil(mockDelegate.didUpdateLocations[1], "Expected a valid second location update but got nil")
    }
}
