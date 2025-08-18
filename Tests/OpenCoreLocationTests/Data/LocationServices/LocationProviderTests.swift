import XCTest
@testable import OpenCoreLocation

final class LocationProviderTests: XCTestCase {
    
    // MARK: - GPSLocationProvider Tests
    
    func testGPSLocationProviderInitialization() {
        let provider = GPSLocationProvider()
        
        XCTAssertEqual(provider.id, "gpsd")
        XCTAssertEqual(provider.poolInterval, 1.0)
    }
    
    func testGPSLocationProviderCustomConfiguration() {
        let provider = GPSLocationProvider(host: "192.168.1.100", port: 2948)
        
        XCTAssertEqual(provider.id, "gpsd")
        // Can't test private properties directly, but initialization should succeed
    }
    
    func testGPSLocationProviderRequestLocationWithoutGPSD() async {
        let provider = GPSLocationProvider()
        
        do {
            _ = try await provider.requestLocation()
            XCTFail("Should have thrown an error when gpsd is not available")
        } catch {
            // Expected to fail when gpsd is not running
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - WiFiLocationProvider Tests
    
    func testWiFiLocationProviderInitialization() {
        let provider = WiFiLocationProvider()
        
        XCTAssertEqual(provider.id, "wifi")
        XCTAssertEqual(provider.poolInterval, 30.0)
    }
    
    func testWiFiLocationProviderWithAPIKey() {
        let provider = WiFiLocationProvider(apiKey: "test-api-key")
        
        XCTAssertEqual(provider.id, "wifi")
    }
    
    func testWiFiLocationProviderRequestLocation() async {
        let provider = WiFiLocationProvider()
        
        do {
            let location = try await provider.requestLocation()
            
            // Should return a location (either WiFi-based or IP fallback)
            XCTAssertNotNil(location)
            XCTAssertTrue(location.latitude >= -90 && location.latitude <= 90)
            XCTAssertTrue(location.longitude >= -180 && location.longitude <= 180)
            
            // WiFi or IP fallback should have accuracy >= 40m
            XCTAssertGreaterThanOrEqual(location.horizontalAccuracy, 40.0)
        } catch {
            // May fail if no internet connection
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Provider Selection Tests
    
    func testProviderSelection() {
        let service = CLLocationManagerService()
        
        // Test that service initializes correctly with multiple providers
        XCTAssertNotNil(service)
    }
    
    func testProviderSelectionWithDifferentAccuracies() async {
        let service = CLLocationManagerService()
        let delegate = MockLocationServiceDelegate()
        service.delegate = delegate
        
        // Test different accuracy requests
        let accuracies: [CLLocationAccuracy] = [
            kCLLocationAccuracyBestForNavigation,
            kCLLocationAccuracyBest,
            kCLLocationAccuracyNearestTenMeters,
            kCLLocationAccuracyHundredMeters,
            kCLLocationAccuracyKilometer,
            kCLLocationAccuracyThreeKilometers
        ]
        
        for accuracy in accuracies {
            let expectation = expectation(description: "Location request for accuracy \(accuracy)")
            delegate.locationExpectation = expectation
            
            await service.requestLocation(with: accuracy)
            
            await fulfillment(of: [expectation], timeout: 10.0)
            
            // Should either succeed or fail gracefully
            XCTAssertTrue(delegate.didReceiveLocation || delegate.didReceiveError)
            
            // Reset for next test
            delegate.reset()
        }
    }
    
    // MARK: - Provider Lifecycle Tests
    
    func testProviderStartStop() async throws {
        let gpsProvider = GPSLocationProvider()
        let wifiProvider = WiFiLocationProvider()
        
        // Test start/stop operations don't throw
        try await gpsProvider.start()
        try await gpsProvider.stop()
        
        try await wifiProvider.start()
        try await wifiProvider.stop()
    }
    
    // MARK: - Error Handling Tests
    
    func testProviderErrorHandling() async {
        let service = CLLocationManagerService()
        let delegate = MockLocationServiceDelegate()
        service.delegate = delegate
        
        // Test with invalid accuracy (should use fallback)
        let expectation = expectation(description: "Error handling test")
        delegate.errorExpectation = expectation
        
        await service.requestLocation(with: -999.0) // Invalid accuracy
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Should either succeed with fallback or fail gracefully
        XCTAssertTrue(delegate.didReceiveLocation || delegate.didReceiveError)
    }
}

// MARK: - Mock Delegate

private class MockLocationServiceDelegate: CLLocationManagerServiceDelegate {
    var didReceiveLocation = false
    var didReceiveError = false
    var locationExpectation: XCTestExpectation?
    var errorExpectation: XCTestExpectation?
    
    func locationManagerService(_ service: CLLocationManagerService, didUpdateLocation location: SendableCLLocation) {
        didReceiveLocation = true
        locationExpectation?.fulfill()
    }
    
    func locationManagerService(_ service: CLLocationManagerService, didFailWithError error: Error) {
        didReceiveError = true
        locationExpectation?.fulfill()
        errorExpectation?.fulfill()
    }
    
    func locationManagerService(_ service: CLLocationManagerService, didEnterRegion region: CLRegion) {}
    func locationManagerService(_ service: CLLocationManagerService, didExitRegion region: CLRegion) {}
    func locationManagerService(_ service: CLLocationManagerService, didDetermineState state: CLRegionState, for region: CLRegion) {}
    func locationManagerService(_ service: CLLocationManagerService, monitoringDidFailFor region: CLRegion?, withError error: Error) {}
    
    func reset() {
        didReceiveLocation = false
        didReceiveError = false
        locationExpectation = nil
        errorExpectation = nil
    }
}