import XCTest
@testable import OpenCoreLocation

final class CLLocationManagerBackgroundTests: XCTestCase {
    
    var locationManager: CLLocationManager!
    var mockDelegate: MockLocationManagerDelegate!
    
    override func setUp() {
        super.setUp()
        locationManager = CLLocationManager()
        mockDelegate = MockLocationManagerDelegate()
        locationManager.delegate = mockDelegate
    }
    
    override func tearDown() {
        locationManager.stopUpdatingLocation()
        locationManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Background Location Updates Tests
    
    func testAllowsBackgroundLocationUpdatesDefaultValue() {
        XCTAssertFalse(locationManager.allowsBackgroundLocationUpdates, 
                      "allowsBackgroundLocationUpdates should be false by default")
    }
    
    func testSetAllowsBackgroundLocationUpdates() {
        // Enable background updates
        locationManager.allowsBackgroundLocationUpdates = true
        XCTAssertTrue(locationManager.allowsBackgroundLocationUpdates, 
                     "allowsBackgroundLocationUpdates should be true after setting")
        
        // Disable background updates
        locationManager.allowsBackgroundLocationUpdates = false
        XCTAssertFalse(locationManager.allowsBackgroundLocationUpdates, 
                      "allowsBackgroundLocationUpdates should be false after unsetting")
    }
    
    // MARK: - Automatic Pausing Tests
    
    func testPausesLocationUpdatesAutomaticallyDefaultValue() {
        XCTAssertFalse(locationManager.pausesLocationUpdatesAutomatically, 
                      "pausesLocationUpdatesAutomatically should be false by default")
    }
    
    func testSetPausesLocationUpdatesAutomatically() {
        // Enable automatic pausing
        locationManager.pausesLocationUpdatesAutomatically = true
        XCTAssertTrue(locationManager.pausesLocationUpdatesAutomatically, 
                     "pausesLocationUpdatesAutomatically should be true after setting")
        
        // Disable automatic pausing
        locationManager.pausesLocationUpdatesAutomatically = false
        XCTAssertFalse(locationManager.pausesLocationUpdatesAutomatically, 
                      "pausesLocationUpdatesAutomatically should be false after unsetting")
    }
    
    // MARK: - Combined Behavior Tests
    
    func testBackgroundUpdatesWithAutomaticPausing() {
        // Configure for background updates with automatic pausing
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // Start location updates
        locationManager.startUpdatingLocation()
        
        // Wait for potential updates
        let expectation = self.expectation(description: "Location update received")
        expectation.isInverted = false // We expect to receive updates
        
        mockDelegate.onLocationUpdate = { locations in
            if !locations.isEmpty {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Verify settings are still active
        XCTAssertTrue(locationManager.allowsBackgroundLocationUpdates)
        XCTAssertTrue(locationManager.pausesLocationUpdatesAutomatically)
    }
    
    func testBackgroundUpdatesWithoutAutomaticPausing() {
        // Configure for background updates without automatic pausing
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        // Start location updates
        locationManager.startUpdatingLocation()
        
        // Create expectation for continuous updates
        let expectation = self.expectation(description: "Multiple location updates")
        expectation.expectedFulfillmentCount = 2 // Expect at least 2 updates
        
        mockDelegate.onLocationUpdate = { locations in
            if !locations.isEmpty {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 35.0) // Longer timeout for background interval
        
        // Verify continuous updates were received
        XCTAssertTrue(locationManager.allowsBackgroundLocationUpdates)
        XCTAssertFalse(locationManager.pausesLocationUpdatesAutomatically)
    }
    
    func testForegroundToBackgroundTransition() {
        // Start in foreground mode
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.startUpdatingLocation()
        
        // Capture initial update count
        var updateCount = 0
        mockDelegate.onLocationUpdate = { _ in
            updateCount += 1
        }
        
        // Wait for some foreground updates
        Thread.sleep(forTimeInterval: 3.0)
        let foregroundUpdateCount = updateCount
        
        // Switch to background mode
        locationManager.allowsBackgroundLocationUpdates = true
        
        // Reset counter and wait for background updates
        updateCount = 0
        Thread.sleep(forTimeInterval: 35.0) // Wait for background interval
        
        let backgroundUpdateCount = updateCount
        
        // Background updates should be less frequent than foreground
        // In 35 seconds: foreground would give ~35 updates, background ~1-2 updates
        XCTAssertLessThan(backgroundUpdateCount, foregroundUpdateCount,
                         "Background updates should be less frequent than foreground updates")
    }
}

// MARK: - Mock Delegate

class MockLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var onLocationUpdate: (([CLLocation]) -> Void)?
    var onError: ((Error) -> Void)?
    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        onLocationUpdate?(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError?(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        onAuthorizationChange?(status)
    }
}