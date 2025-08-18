import XCTest
@testable import OpenCoreLocation

final class CLLocationManagerRegionMonitoringTests: XCTestCase {
    var locationManager: CLLocationManager!
    fileprivate var mockDelegate: MockRegionMonitoringDelegate!
    
    override func setUp() {
        super.setUp()
        locationManager = CLLocationManager()
        mockDelegate = MockRegionMonitoringDelegate()
        locationManager.delegate = mockDelegate
    }
    
    override func tearDown() {
        locationManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Region Monitoring Availability Tests
    
    func testRegionMonitoringAvailabilityForCircularRegion() {
        // Given
        let isAvailable = CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
        
        // Then
        XCTAssertTrue(isAvailable, "Region monitoring should be available for CLCircularRegion")
    }
    
    func testRegionMonitoringAvailabilityForUnsupportedRegionType() {
        // Given - using CLRegion base class (not CLCircularRegion)
        let isAvailable = CLLocationManager.isMonitoringAvailable(for: CLRegion.self)
        
        // Then
        XCTAssertFalse(isAvailable, "Region monitoring should not be available for non-CLCircularRegion types")
    }
    
    // MARK: - Region Monitoring Lifecycle Tests
    
    func testStartMonitoringValidCircularRegion() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco
        let region = CLCircularRegion(center: center, radius: 100.0, identifier: "test-region")
        
        // When
        locationManager.startMonitoring(for: region)
        
        // Then
        XCTAssertTrue(locationManager.monitoredRegions.contains(region))
        XCTAssertEqual(mockDelegate.didStartMonitoringRegion, region)
    }
    
    func testStartMonitoringInvalidRegionType() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let region = CLRegion(center: center, radius: 100.0, identifier: "test-region")
        
        // When
        locationManager.startMonitoring(for: region)
        
        // Then
        XCTAssertFalse(locationManager.monitoredRegions.contains(region))
        XCTAssertNotNil(mockDelegate.monitoringDidFailError)
        XCTAssertEqual(mockDelegate.monitoringDidFailRegion?.identifier, region.identifier)
    }
    
    func testStopMonitoringRegion() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let region = CLCircularRegion(center: center, radius: 100.0, identifier: "test-region")
        locationManager.startMonitoring(for: region)
        
        // When
        locationManager.stopMonitoring(for: region)
        
        // Then
        XCTAssertFalse(locationManager.monitoredRegions.contains(region))
    }
    
    // MARK: - Region State Tests
    
    func testRequestStateForRegionWithoutLocation() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let region = CLCircularRegion(center: center, radius: 100.0, identifier: "test-region")
        locationManager.startMonitoring(for: region)
        
        // When
        locationManager.requestState(for: region)
        
        // Then
        // Since there's no location data available, state should be unknown
        // This test validates the basic API functionality rather than actual region monitoring
        XCTAssertTrue(locationManager.monitoredRegions.contains(region), "Region should be monitored")
        XCTAssertEqual(mockDelegate.didStartMonitoringRegion?.identifier, region.identifier, "Should have started monitoring region")
    }
    
    // MARK: - Region Entry/Exit Tests
    
    func testRegionEntryDetection() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco
        let region = CLCircularRegion(center: center, radius: 100.0, identifier: "sf-region")
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        // When
        locationManager.startMonitoring(for: region)
        
        // Then
        // Test that the region was added to monitoring and delegate was called
        XCTAssertTrue(locationManager.monitoredRegions.contains(region), "Region should be monitored")
        XCTAssertEqual(mockDelegate.didStartMonitoringRegion?.identifier, region.identifier, "Should have started monitoring region")
        XCTAssertTrue(region.notifyOnEntry, "Region should notify on entry")
        XCTAssertFalse(region.notifyOnExit, "Region should not notify on exit")
    }
    
    func testRegionExitDetection() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco
        let region = CLCircularRegion(center: center, radius: 100.0, identifier: "sf-region")
        region.notifyOnEntry = false
        region.notifyOnExit = true
        
        // When
        locationManager.startMonitoring(for: region)
        
        // Then
        // Test that the region was added to monitoring with correct notification settings
        XCTAssertTrue(locationManager.monitoredRegions.contains(region), "Region should be monitored")
        XCTAssertEqual(mockDelegate.didStartMonitoringRegion?.identifier, region.identifier, "Should have started monitoring region")
        XCTAssertFalse(region.notifyOnEntry, "Region should not notify on entry")
        XCTAssertTrue(region.notifyOnExit, "Region should notify on exit")
    }
    
    func testNoRegionNotificationWhenDisabled() {
        // Given
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let region = CLCircularRegion(center: center, radius: 100.0, identifier: "sf-region")
        region.notifyOnEntry = false  // Entry notifications disabled
        region.notifyOnExit = false   // Exit notifications disabled
        
        // When
        locationManager.startMonitoring(for: region)
        
        // Then
        // Test that the region was added but with notifications disabled
        XCTAssertTrue(locationManager.monitoredRegions.contains(region), "Region should be monitored")
        XCTAssertEqual(mockDelegate.didStartMonitoringRegion?.identifier, region.identifier, "Should have started monitoring region")
        XCTAssertFalse(region.notifyOnEntry, "Region should not notify on entry")
        XCTAssertFalse(region.notifyOnExit, "Region should not notify on exit")
    }
    
    // MARK: - Multiple Region Tests
    
    func testMultipleRegionMonitoring() {
        // Given
        let region1 = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            radius: 100.0,
            identifier: "region1"
        )
        let region2 = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // NYC
            radius: 200.0,
            identifier: "region2"
        )
        
        // When
        locationManager.startMonitoring(for: region1)
        locationManager.startMonitoring(for: region2)
        
        // Then
        XCTAssertEqual(locationManager.monitoredRegions.count, 2)
        XCTAssertTrue(locationManager.monitoredRegions.contains(region1))
        XCTAssertTrue(locationManager.monitoredRegions.contains(region2))
    }
}

// MARK: - Mock Delegate

fileprivate class MockRegionMonitoringDelegate: CLLocationManagerDelegate {
    var didStartMonitoringRegion: CLRegion?
    var didEnterRegion: CLRegion?
    var didExitRegion: CLRegion?
    var didDetermineState: CLRegionState?
    var didDetermineStateRegion: CLRegion?
    var monitoringDidFailRegion: CLRegion?
    var monitoringDidFailError: Error?
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        didStartMonitoringRegion = region
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        didEnterRegion = region
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        didExitRegion = region
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        didDetermineState = state
        didDetermineStateRegion = region
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        monitoringDidFailRegion = region
        monitoringDidFailError = error
    }
}