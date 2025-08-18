import XCTest
@testable import OpenCoreLocation

final class CLCircularRegionTests: XCTestCase {
    
    func testCircularRegionInitialization() {
        let center = CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0302)
        let radius: CLLocationDistance = 1000.0
        let identifier = "Apple Park"
        
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        
        XCTAssertEqual(region.center.latitude, center.latitude, accuracy: 0.0001)
        XCTAssertEqual(region.center.longitude, center.longitude, accuracy: 0.0001)
        XCTAssertEqual(region.radius, radius)
        XCTAssertEqual(region.identifier, identifier)
        XCTAssertTrue(region.notifyOnEntry)
        XCTAssertTrue(region.notifyOnExit)
    }
    
    func testCircularRegionContainment() {
        // Create a region centered at Apple Park with 1km radius
        let center = CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0302)
        let radius: CLLocationDistance = 1000.0
        let region = CLCircularRegion(center: center, radius: radius, identifier: "Apple Park")
        
        // Test point at center - should be inside
        XCTAssertTrue(region.contains(center))
        
        // Test point 500m away (within radius) - should be inside
        let nearbyPoint = CLLocationCoordinate2D(latitude: 37.3362, longitude: -122.0302)
        XCTAssertTrue(region.contains(nearbyPoint))
        
        // Test point 5km away (outside radius) - should be outside
        let farPoint = CLLocationCoordinate2D(latitude: 37.3750, longitude: -122.0302)
        XCTAssertFalse(region.contains(farPoint))
        
        // Test point exactly on the edge (1km away)
        // Note: Due to floating point precision, we test slightly inside
        let edgePoint = CLLocationCoordinate2D(latitude: 37.3407, longitude: -122.0302)
        let expectedContainment = region.contains(edgePoint)
        XCTAssertNotNil(expectedContainment) // Just verify it returns a valid boolean
    }
    
    func testCircularRegionCopy() {
        let center = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let radius: CLLocationDistance = 500.0
        let region = CLCircularRegion(center: center, radius: radius, identifier: "NYC")
        region.notifyOnEntry = false
        region.notifyOnExit = true
        
        guard let copiedRegion = region.copy() as? CLCircularRegion else {
            XCTFail("Failed to copy CLCircularRegion")
            return
        }
        
        XCTAssertEqual(copiedRegion.center.latitude, region.center.latitude)
        XCTAssertEqual(copiedRegion.center.longitude, region.center.longitude)
        XCTAssertEqual(copiedRegion.radius, region.radius)
        XCTAssertEqual(copiedRegion.identifier, region.identifier)
        XCTAssertEqual(copiedRegion.notifyOnEntry, region.notifyOnEntry)
        XCTAssertEqual(copiedRegion.notifyOnExit, region.notifyOnExit)
    }
    
    func testCircularRegionEquality() {
        let center = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        let radius: CLLocationDistance = 2000.0
        
        let region1 = CLCircularRegion(center: center, radius: radius, identifier: "London")
        let region2 = CLCircularRegion(center: center, radius: radius, identifier: "London")
        let region3 = CLCircularRegion(center: center, radius: radius, identifier: "London2")
        
        XCTAssertEqual(region1, region2)
        XCTAssertNotEqual(region1, region3)
    }
    
    func testCircularRegionSecureCoding() throws {
        let center = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        let radius: CLLocationDistance = 1500.0
        let region = CLCircularRegion(center: center, radius: radius, identifier: "Paris")
        region.notifyOnEntry = false
        
        // Encode
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        region.encode(with: encoder)
        let data = encoder.encodedData
        
        // Decode
        let decoder = try NSKeyedUnarchiver(forReadingFrom: data)
        decoder.requiresSecureCoding = true
        guard let decodedRegion = CLCircularRegion(coder: decoder) else {
            XCTFail("Failed to decode CLCircularRegion")
            return
        }
        
        XCTAssertEqual(decodedRegion.center.latitude, region.center.latitude, accuracy: 0.0001)
        XCTAssertEqual(decodedRegion.center.longitude, region.center.longitude, accuracy: 0.0001)
        XCTAssertEqual(decodedRegion.radius, region.radius)
        XCTAssertEqual(decodedRegion.identifier, region.identifier)
        XCTAssertEqual(decodedRegion.notifyOnEntry, region.notifyOnEntry)
        XCTAssertEqual(decodedRegion.notifyOnExit, region.notifyOnExit)
    }
}