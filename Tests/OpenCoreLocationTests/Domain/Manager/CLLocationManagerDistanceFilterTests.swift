import XCTest
@testable import OpenCoreLocation

final class CLLocationManagerDistanceFilterTests: XCTestCase {
    
    private var locationManager: CLLocationManager!
    private var delegate: MockDistanceFilterDelegate!
    
    override func setUp() async throws {
        try await super.setUp()
        locationManager = CLLocationManager()
        delegate = MockDistanceFilterDelegate()
        locationManager.delegate = delegate
    }
    
    override func tearDown() async throws {
        locationManager.stopUpdatingLocation()
        locationManager = nil
        delegate = nil
        try await super.tearDown()
    }
    
    // MARK: - Distance Filter Configuration Tests
    
    func testDistanceFilterDefaultValue() {
        XCTAssertEqual(locationManager.distanceFilter, 10.0)
    }
    
    func testDistanceFilterSetting() {
        locationManager.distanceFilter = 50.0
        XCTAssertEqual(locationManager.distanceFilter, 50.0)
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        XCTAssertEqual(locationManager.distanceFilter, kCLDistanceFilterNone)
    }
    
    // MARK: - Distance Filter Behavior Tests
    
    func testDistanceFilterDisabled() async throws {
        // Disable distance filter
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        let expectation = expectation(description: "Should receive all location updates")
        expectation.expectedFulfillmentCount = 1
        delegate.locationUpdateExpectation = expectation
        
        // Request authorization and start location updates
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Should receive location update since filter is disabled
        XCTAssertTrue(delegate.receivedLocationUpdates.count >= 1)
    }
    
    func testDistanceFilterWithinThreshold() async throws {
        // Set small distance filter
        locationManager.distanceFilter = 1000.0 // 1 km
        
        // Since our test environment likely uses IP-based location (which doesn't move much),
        // we should receive the first location but subsequent ones should be filtered
        let expectation = expectation(description: "Should receive first location")
        delegate.locationUpdateExpectation = expectation
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        await fulfillment(of: [expectation], timeout: 10.0)
        
        // Should receive at least the first location
        XCTAssertTrue(delegate.receivedLocationUpdates.count >= 1)
        
        // Wait a bit more and verify we don't get excessive updates
        let initialCount = delegate.receivedLocationUpdates.count
        
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        // Should not receive many more updates due to distance filtering
        // (IP-based location doesn't change much)
        let finalCount = delegate.receivedLocationUpdates.count
        XCTAssertTrue(finalCount <= initialCount + 2) // Allow some variance for timing
    }
    
    func testDistanceFilterReset() async throws {
        locationManager.distanceFilter = 10.0
        
        let firstExpectation = expectation(description: "First location session")
        delegate.locationUpdateExpectation = firstExpectation
        
        // Start first location session
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        await fulfillment(of: [firstExpectation], timeout: 5.0)
        let firstLocationCount = delegate.receivedLocationUpdates.count
        
        // Stop location updates (should reset distance filter)
        locationManager.stopUpdatingLocation()
        
        // Clear delegate and start again
        delegate.reset()
        let secondExpectation = expectation(description: "Second location session")
        delegate.locationUpdateExpectation = secondExpectation
        
        locationManager.startUpdatingLocation()
        
        await fulfillment(of: [secondExpectation], timeout: 5.0)
        
        // Should receive location again (filter was reset)
        XCTAssertTrue(delegate.receivedLocationUpdates.count >= 1)
    }
    
    // MARK: - Distance Calculation Tests
    
    func testDistanceCalculationAccuracy() {
        // Test the distance calculation used internally
        // This tests the haversine formula implementation indirectly
        
        // Create two locations approximately 100 meters apart
        let location1 = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
        let location2 = CLLocation(latitude: 37.7758, longitude: -122.4194) // ~100m north
        
        let calculatedDistance = location1.distance(from: location2)
        
        // Should be approximately 100 meters (within reasonable tolerance)
        XCTAssertTrue(calculatedDistance > 90 && calculatedDistance < 110, 
                     "Distance calculation should be approximately 100m, got \(calculatedDistance)m")
    }
    
    func testDistanceFilterIntegration() async throws {
        // Test that distance filter properly integrates with location updates
        
        // Set a very large distance filter
        locationManager.distanceFilter = 10000.0 // 10 km
        
        let expectation = expectation(description: "Should receive first location only")
        delegate.locationUpdateExpectation = expectation
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        await fulfillment(of: [expectation], timeout: 8.0)
        
        let initialCount = delegate.receivedLocationUpdates.count
        
        // Wait for additional potential updates
        try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        
        // Should not receive additional updates due to large distance filter
        // (assuming IP-based location doesn't move 10km in 5 seconds)
        let finalCount = delegate.receivedLocationUpdates.count
        XCTAssertEqual(finalCount, initialCount, "Should not receive additional updates with large distance filter")
    }
    
    // MARK: - Edge Cases
    
    func testNegativeDistanceFilter() {
        // Negative values should disable the filter (behave like kCLDistanceFilterNone)
        locationManager.distanceFilter = -1.0
        
        // Should not crash and should accept the value
        XCTAssertEqual(locationManager.distanceFilter, -1.0)
    }
    
    func testZeroDistanceFilter() {
        // Zero should disable the filter
        locationManager.distanceFilter = 0.0
        
        XCTAssertEqual(locationManager.distanceFilter, 0.0)
    }
    
    func testVerySmallDistanceFilter() async throws {
        // Very small distance filter should still work
        locationManager.distanceFilter = 0.1 // 10cm
        
        let expectation = expectation(description: "Should work with small filter")
        delegate.locationUpdateExpectation = expectation
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        XCTAssertTrue(delegate.receivedLocationUpdates.count >= 1)
    }
}

// MARK: - Mock Delegate

private class MockDistanceFilterDelegate: NSObject, CLLocationManagerDelegate {
    var receivedLocationUpdates: [CLLocation] = []
    var receivedErrors: [Error] = []
    var locationUpdateExpectation: XCTestExpectation?
    var errorExpectation: XCTestExpectation?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        receivedLocationUpdates.append(contentsOf: locations)
        locationUpdateExpectation?.fulfill()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        receivedErrors.append(error)
        errorExpectation?.fulfill()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle authorization changes if needed
    }
    
    func reset() {
        receivedLocationUpdates.removeAll()
        receivedErrors.removeAll()
        locationUpdateExpectation = nil
        errorExpectation = nil
    }
}