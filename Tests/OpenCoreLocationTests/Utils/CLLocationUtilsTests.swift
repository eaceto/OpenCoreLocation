import XCTest
@testable import OpenCoreLocation

final class CLLocationUtilsTests: XCTestCase {
    
    // MARK: - Distance Calculation Tests
    
    func testDistanceCalculationBetweenIdenticalPoints() {
        let coord1 = (latitude: 37.7749, longitude: -122.4194)
        let coord2 = (latitude: 37.7749, longitude: -122.4194)
        
        let distance = CLLocationUtils.calculateDistance(from: coord1, to: coord2)
        
        XCTAssertEqual(distance, 0.0, accuracy: 0.1, "Distance between identical points should be 0")
    }
    
    func testDistanceCalculationBetweenKnownPoints() {
        // San Francisco to New York (approximate distance: 4,130 km)
        let sanFrancisco = (latitude: 37.7749, longitude: -122.4194)
        let newYork = (latitude: 40.7128, longitude: -74.0060)
        
        let distance = CLLocationUtils.calculateDistance(from: sanFrancisco, to: newYork)
        
        // Expected distance is approximately 4,130,000 meters (4,130 km)
        XCTAssertTrue(distance > 4_100_000 && distance < 4_160_000, 
                     "Distance from SF to NYC should be ~4,130km, got \(distance/1000)km")
    }
    
    func testDistanceCalculationWithCLLocation() {
        let location1 = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let location2 = CLLocation(latitude: 37.7849, longitude: -122.4194) // ~1km north
        
        let utilsDistance = CLLocationUtils.calculateDistance(from: location1, to: location2)
        let coreLocationDistance = location1.distance(from: location2)
        
        // Should match CLLocation's built-in distance calculation
        XCTAssertEqual(utilsDistance, coreLocationDistance, accuracy: 1.0,
                      "Utils distance should match CLLocation distance calculation")
    }
    
    func testDistanceCalculationWithCLLocationCoordinate2D() {
        let coord1 = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278) // London
        let coord2 = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)  // Paris
        
        let distance = CLLocationUtils.calculateDistance(from: coord1, to: coord2)
        
        // London to Paris is approximately 344 km
        XCTAssertTrue(distance > 340_000 && distance < 350_000,
                     "Distance from London to Paris should be ~344km, got \(distance/1000)km")
    }
    
    func testDistanceCalculationAtPoles() {
        let northPole = (latitude: 90.0, longitude: 0.0)
        let nearNorthPole = (latitude: 89.99, longitude: 0.0)
        
        let distance = CLLocationUtils.calculateDistance(from: northPole, to: nearNorthPole)
        
        // 0.01 degrees at the pole should be approximately 1.11 km
        XCTAssertTrue(distance > 1000 && distance < 1200,
                     "Distance near poles should be calculated correctly")
    }
    
    func testDistanceCalculationAcrossAntimeridian() {
        let east = (latitude: 0.0, longitude: 179.0)
        let west = (latitude: 0.0, longitude: -179.0)
        
        let distance = CLLocationUtils.calculateDistance(from: east, to: west)
        
        // Should be about 222 km (2 degrees at equator)
        XCTAssertTrue(distance > 200_000 && distance < 250_000,
                     "Distance across antimeridian should be calculated correctly")
    }
    
    // MARK: - Coordinate Validation Tests
    
    func testValidCoordinateValidation() {
        // Valid coordinates
        XCTAssertTrue(CLLocationUtils.isValidCoordinate(latitude: 0.0, longitude: 0.0))
        XCTAssertTrue(CLLocationUtils.isValidCoordinate(latitude: 90.0, longitude: 180.0))
        XCTAssertTrue(CLLocationUtils.isValidCoordinate(latitude: -90.0, longitude: -180.0))
        XCTAssertTrue(CLLocationUtils.isValidCoordinate(latitude: 37.7749, longitude: -122.4194))
        
        let validCoord = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        XCTAssertTrue(CLLocationUtils.isValidCoordinate(validCoord))
    }
    
    func testInvalidCoordinateValidation() {
        // Invalid latitudes
        XCTAssertFalse(CLLocationUtils.isValidCoordinate(latitude: 91.0, longitude: 0.0))
        XCTAssertFalse(CLLocationUtils.isValidCoordinate(latitude: -91.0, longitude: 0.0))
        
        // Invalid longitudes
        XCTAssertFalse(CLLocationUtils.isValidCoordinate(latitude: 0.0, longitude: 181.0))
        XCTAssertFalse(CLLocationUtils.isValidCoordinate(latitude: 0.0, longitude: -181.0))
        
        // NaN values
        XCTAssertFalse(CLLocationUtils.isValidCoordinate(latitude: Double.nan, longitude: 0.0))
        XCTAssertFalse(CLLocationUtils.isValidCoordinate(latitude: 0.0, longitude: Double.nan))
        
        let invalidCoord = CLLocationCoordinate2D(latitude: 100.0, longitude: 200.0)
        XCTAssertFalse(CLLocationUtils.isValidCoordinate(invalidCoord))
    }
    
    // MARK: - Bearing Calculation Tests
    
    func testBearingCalculationNorth() {
        let from = (latitude: 0.0, longitude: 0.0)
        let to = (latitude: 1.0, longitude: 0.0)
        
        let bearing = CLLocationUtils.calculateBearing(from: from, to: to)
        
        XCTAssertEqual(bearing, 0.0, accuracy: 0.1, "Bearing due north should be 0°")
    }
    
    func testBearingCalculationEast() {
        let from = (latitude: 0.0, longitude: 0.0)
        let to = (latitude: 0.0, longitude: 1.0)
        
        let bearing = CLLocationUtils.calculateBearing(from: from, to: to)
        
        XCTAssertEqual(bearing, 90.0, accuracy: 0.1, "Bearing due east should be 90°")
    }
    
    func testBearingCalculationSouth() {
        let from = (latitude: 1.0, longitude: 0.0)
        let to = (latitude: 0.0, longitude: 0.0)
        
        let bearing = CLLocationUtils.calculateBearing(from: from, to: to)
        
        XCTAssertEqual(bearing, 180.0, accuracy: 0.1, "Bearing due south should be 180°")
    }
    
    func testBearingCalculationWest() {
        let from = (latitude: 0.0, longitude: 1.0)
        let to = (latitude: 0.0, longitude: 0.0)
        
        let bearing = CLLocationUtils.calculateBearing(from: from, to: to)
        
        XCTAssertEqual(bearing, 270.0, accuracy: 0.1, "Bearing due west should be 270°")
    }
    
    // MARK: - Constants Tests
    
    func testConstants() {
        XCTAssertEqual(CLLocationUtils.earthRadiusMeters, 6371000)
        XCTAssertEqual(CLLocationUtils.earthRadiusKilometers, 6371)
        XCTAssertEqual(CLLocationUtils.maxLatitude, 90.0)
        XCTAssertEqual(CLLocationUtils.minLatitude, -90.0)
        XCTAssertEqual(CLLocationUtils.maxLongitude, 180.0)
        XCTAssertEqual(CLLocationUtils.minLongitude, -180.0)
    }
    
    // MARK: - Extension Tests
    
    func testCLLocationCoordinate2DExtensions() {
        let london = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        let paris = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        
        let distance = london.distance(to: paris)
        let bearing = london.bearing(to: paris)
        
        XCTAssertTrue(distance > 340_000 && distance < 350_000, "Extension distance calculation should work")
        XCTAssertTrue(bearing > 140 && bearing < 160, "Extension bearing calculation should work")
        XCTAssertTrue(london.isValid, "London coordinates should be valid")
        
        let invalidCoord = CLLocationCoordinate2D(latitude: 100, longitude: 200)
        XCTAssertFalse(invalidCoord.isValid, "Invalid coordinates should be detected")
    }
    
    // MARK: - Performance Tests
    
    func testDistanceCalculationPerformance() {
        let coord1 = (latitude: 37.7749, longitude: -122.4194)
        let coord2 = (latitude: 40.7128, longitude: -74.0060)
        
        measure {
            for _ in 0..<10000 {
                _ = CLLocationUtils.calculateDistance(from: coord1, to: coord2)
            }
        }
    }
}