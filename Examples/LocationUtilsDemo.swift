import Foundation
import OpenCoreLocation

/// Example demonstrating CLLocationUtils functionality
class LocationUtilsDemo {
    
    func demonstrateLocationUtils() {
        print("=== CLLocationUtils Demo ===\n")
        
        // Define some famous locations
        let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let newYork = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let london = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        let paris = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        let tokyo = CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)
        
        print("📍 Famous Locations:")
        print("   San Francisco: \(sanFrancisco.latitude), \(sanFrancisco.longitude)")
        print("   New York: \(newYork.latitude), \(newYork.longitude)")
        print("   London: \(london.latitude), \(london.longitude)")
        print("   Paris: \(paris.latitude), \(paris.longitude)")
        print("   Tokyo: \(tokyo.latitude), \(tokyo.longitude)")
        print("")
        
        // Distance calculations
        print("🌍 Distance Calculations:")
        demonstrateDistanceCalculations(sanFrancisco: sanFrancisco, newYork: newYork, 
                                      london: london, paris: paris, tokyo: tokyo)
        
        // Bearing calculations
        print("🧭 Bearing Calculations:")
        demonstrateBearingCalculations(sanFrancisco: sanFrancisco, newYork: newYork, 
                                     london: london, paris: paris, tokyo: tokyo)
        
        // Coordinate validation
        print("✅ Coordinate Validation:")
        demonstrateCoordinateValidation()
        
        // Extension methods
        print("🔧 Extension Methods:")
        demonstrateExtensionMethods(london: london, paris: paris)
        
        // Constants
        print("📏 Constants:")
        demonstrateConstants()
    }
    
    private func demonstrateDistanceCalculations(sanFrancisco: CLLocationCoordinate2D, 
                                               newYork: CLLocationCoordinate2D,
                                               london: CLLocationCoordinate2D, 
                                               paris: CLLocationCoordinate2D,
                                               tokyo: CLLocationCoordinate2D) {
        
        let sfToNy = CLLocationUtils.calculateDistance(from: sanFrancisco, to: newYork)
        let londonToParis = CLLocationUtils.calculateDistance(from: london, to: paris)
        let sfToTokyo = CLLocationUtils.calculateDistance(from: sanFrancisco, to: tokyo)
        
        print("   San Francisco → New York: \(formatDistance(sfToNy))")
        print("   London → Paris: \(formatDistance(londonToParis))")
        print("   San Francisco → Tokyo: \(formatDistance(sfToTokyo))")
        
        // Compare different calculation methods
        let tuple1 = (latitude: sanFrancisco.latitude, longitude: sanFrancisco.longitude)
        let tuple2 = (latitude: newYork.latitude, longitude: newYork.longitude)
        let tupleDistance = CLLocationUtils.calculateDistance(from: tuple1, to: tuple2)
        
        let location1 = CLLocation(latitude: sanFrancisco.latitude, longitude: sanFrancisco.longitude)
        let location2 = CLLocation(latitude: newYork.latitude, longitude: newYork.longitude)
        let locationDistance = CLLocationUtils.calculateDistance(from: location1, to: location2)
        
        print("   Different methods give same result:")
        print("     Coordinate method: \(formatDistance(sfToNy))")
        print("     Tuple method: \(formatDistance(tupleDistance))")
        print("     CLLocation method: \(formatDistance(locationDistance))")
        print("")
    }
    
    private func demonstrateBearingCalculations(sanFrancisco: CLLocationCoordinate2D, 
                                              newYork: CLLocationCoordinate2D,
                                              london: CLLocationCoordinate2D, 
                                              paris: CLLocationCoordinate2D,
                                              tokyo: CLLocationCoordinate2D) {
        
        let sfToNy = CLLocationUtils.calculateBearing(
            from: (latitude: sanFrancisco.latitude, longitude: sanFrancisco.longitude),
            to: (latitude: newYork.latitude, longitude: newYork.longitude)
        )
        
        let londonToParis = CLLocationUtils.calculateBearing(
            from: (latitude: london.latitude, longitude: london.longitude),
            to: (latitude: paris.latitude, longitude: paris.longitude)
        )
        
        let sfToTokyo = CLLocationUtils.calculateBearing(
            from: (latitude: sanFrancisco.latitude, longitude: sanFrancisco.longitude),
            to: (latitude: tokyo.latitude, longitude: tokyo.longitude)
        )
        
        print("   San Francisco → New York: \(formatBearing(sfToNy))")
        print("   London → Paris: \(formatBearing(londonToParis))")
        print("   San Francisco → Tokyo: \(formatBearing(sfToTokyo))")
        print("")
    }
    
    private func demonstrateCoordinateValidation() {
        let validCoords = [
            (37.7749, -122.4194, "San Francisco"),
            (0.0, 0.0, "Equator/Prime Meridian"),
            (90.0, 0.0, "North Pole"),
            (-90.0, 0.0, "South Pole")
        ]
        
        let invalidCoords = [
            (91.0, 0.0, "Invalid latitude > 90"),
            (-91.0, 0.0, "Invalid latitude < -90"),
            (0.0, 181.0, "Invalid longitude > 180"),
            (0.0, -181.0, "Invalid longitude < -180"),
            (Double.nan, 0.0, "NaN latitude")
        ]
        
        print("   Valid coordinates:")
        for (lat, lon, desc) in validCoords {
            let isValid = CLLocationUtils.isValidCoordinate(latitude: lat, longitude: lon)
            print("     \(desc): \(isValid ? "✅" : "❌")")
        }
        
        print("   Invalid coordinates:")
        for (lat, lon, desc) in invalidCoords {
            let isValid = CLLocationUtils.isValidCoordinate(latitude: lat, longitude: lon)
            print("     \(desc): \(isValid ? "✅" : "❌")")
        }
        print("")
    }
    
    private func demonstrateExtensionMethods(london: CLLocationCoordinate2D, paris: CLLocationCoordinate2D) {
        // Using extension methods
        let distance = london.distance(to: paris)
        let bearing = london.bearing(to: paris)
        let isValid = london.isValid
        
        print("   Using CLLocationCoordinate2D extensions:")
        print("     London to Paris distance: \(formatDistance(distance))")
        print("     London to Paris bearing: \(formatBearing(bearing))")
        print("     London coordinates valid: \(isValid ? "✅" : "❌")")
        
        let invalidCoord = CLLocationCoordinate2D(latitude: 100, longitude: 200)
        print("     Invalid coord (100, 200) valid: \(invalidCoord.isValid ? "✅" : "❌")")
        print("")
    }
    
    private func demonstrateConstants() {
        print("   Earth radius (meters): \(CLLocationUtils.earthRadiusMeters)")
        print("   Earth radius (kilometers): \(CLLocationUtils.earthRadiusKilometers)")
        print("   Max latitude: \(CLLocationUtils.maxLatitude)°")
        print("   Min latitude: \(CLLocationUtils.minLatitude)°")
        print("   Max longitude: \(CLLocationUtils.maxLongitude)°")
        print("   Min longitude: \(CLLocationUtils.minLongitude)°")
        print("")
    }
    
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return String(format: "%.1f meters", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    private func formatBearing(_ bearing: CLLocationDirection) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((bearing + 22.5) / 45.0) % 8
        return String(format: "%.1f° (%@)", bearing, directions[index])
    }
}

// MARK: - Main Entry Point

@main
struct LocationUtilsMain {
    static func main() {
        let demo = LocationUtilsDemo()
        demo.demonstrateLocationUtils()
    }
}