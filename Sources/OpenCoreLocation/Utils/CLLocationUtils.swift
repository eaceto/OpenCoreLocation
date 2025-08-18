import Foundation

// MARK: - CLLocationUtils
/// Utility functions for location calculations and coordinate operations.
/// This class provides common geographic calculations used throughout the OpenCoreLocation framework.
public final class CLLocationUtils {
    
    // MARK: - Distance Calculations
    
    /// Calculates the great-circle distance between two coordinate points using the haversine formula.
    /// 
    /// The haversine formula determines the shortest distance over the earth's surface,
    /// giving an accurate measurement for most practical purposes.
    /// 
    /// - Parameters:
    ///   - from: Starting coordinate (latitude, longitude) in degrees
    ///   - to: Ending coordinate (latitude, longitude) in degrees
    /// - Returns: Distance in meters
    /// 
    /// ## Example Usage:
    /// ```swift
    /// let distance = CLLocationUtils.calculateDistance(
    ///     from: (latitude: 37.7749, longitude: -122.4194),  // San Francisco
    ///     to: (latitude: 40.7128, longitude: -74.0060)      // New York
    /// )
    /// print("Distance: \(distance) meters")  // ~4,134,000 meters
    /// ```
    public static func calculateDistance(
        from: (latitude: Double, longitude: Double),
        to: (latitude: Double, longitude: Double)
    ) -> CLLocationDistance {
        // Convert degrees to radians
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180
        
        // Calculate differences
        let dLat = lat2 - lat1
        let dLon = lon2 - lon1
        
        // Haversine formula
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        // Earth radius in meters (mean radius)
        let R: CLLocationDistance = 6371000
        
        return R * c
    }
    
    /// Calculates the great-circle distance between two CLLocation objects.
    /// 
    /// Convenience method that extracts coordinates from CLLocation objects
    /// and delegates to the coordinate-based distance calculation.
    /// 
    /// - Parameters:
    ///   - from: Starting CLLocation
    ///   - to: Ending CLLocation
    /// - Returns: Distance in meters
    public static func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        return calculateDistance(
            from: (latitude: from.coordinate.latitude, longitude: from.coordinate.longitude),
            to: (latitude: to.coordinate.latitude, longitude: to.coordinate.longitude)
        )
    }
    
    /// Calculates the great-circle distance between two CLLocationCoordinate2D objects.
    /// 
    /// Convenience method for working directly with coordinate structures.
    /// 
    /// - Parameters:
    ///   - from: Starting coordinate
    ///   - to: Ending coordinate
    /// - Returns: Distance in meters
    public static func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        return calculateDistance(
            from: (latitude: from.latitude, longitude: from.longitude),
            to: (latitude: to.latitude, longitude: to.longitude)
        )
    }
    
    // MARK: - Coordinate Validation
    
    /// Validates that a coordinate is within valid latitude/longitude ranges.
    /// 
    /// - Parameter coordinate: The coordinate to validate
    /// - Returns: True if the coordinate has valid latitude (-90 to 90) and longitude (-180 to 180)
    public static func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude >= -90.0 && coordinate.latitude <= 90.0 &&
               coordinate.longitude >= -180.0 && coordinate.longitude <= 180.0 &&
               !coordinate.latitude.isNaN && !coordinate.longitude.isNaN
    }
    
    /// Validates that latitude and longitude values are within valid ranges.
    /// 
    /// - Parameters:
    ///   - latitude: Latitude in degrees (-90 to 90)
    ///   - longitude: Longitude in degrees (-180 to 180)
    /// - Returns: True if both values are within valid ranges
    public static func isValidCoordinate(latitude: Double, longitude: Double) -> Bool {
        return latitude >= -90.0 && latitude <= 90.0 &&
               longitude >= -180.0 && longitude <= 180.0 &&
               !latitude.isNaN && !longitude.isNaN
    }
    
    // MARK: - Bearing Calculations
    
    /// Calculates the initial bearing (forward azimuth) from one coordinate to another.
    /// 
    /// The bearing is the compass direction from the starting point to the ending point,
    /// measured in degrees clockwise from true north.
    /// 
    /// - Parameters:
    ///   - from: Starting coordinate
    ///   - to: Ending coordinate
    /// - Returns: Bearing in degrees (0-360), where 0° is north, 90° is east, etc.
    public static func calculateBearing(
        from: (latitude: Double, longitude: Double),
        to: (latitude: Double, longitude: Double)
    ) -> CLLocationDirection {
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let deltaLon = (to.longitude - from.longitude) * .pi / 180
        
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        
        let bearing = atan2(y, x) * 180 / .pi
        
        // Normalize to 0-360 degrees
        return bearing >= 0 ? bearing : bearing + 360
    }
    
    // MARK: - Constants
    
    /// Earth's mean radius in meters
    public static let earthRadiusMeters: CLLocationDistance = 6371000
    
    /// Earth's mean radius in kilometers
    public static let earthRadiusKilometers: CLLocationDistance = 6371
    
    /// Maximum valid latitude value in degrees
    public static let maxLatitude: CLLocationDegrees = 90.0
    
    /// Minimum valid latitude value in degrees
    public static let minLatitude: CLLocationDegrees = -90.0
    
    /// Maximum valid longitude value in degrees
    public static let maxLongitude: CLLocationDegrees = 180.0
    
    /// Minimum valid longitude value in degrees
    public static let minLongitude: CLLocationDegrees = -180.0
}

// MARK: - CLLocationCoordinate2D Extensions
public extension CLLocationCoordinate2D {
    
    /// Calculates the distance to another coordinate using the haversine formula.
    /// - Parameter other: The destination coordinate
    /// - Returns: Distance in meters
    func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
        return CLLocationUtils.calculateDistance(from: self, to: other)
    }
    
    /// Calculates the bearing to another coordinate.
    /// - Parameter other: The destination coordinate
    /// - Returns: Bearing in degrees (0-360)
    func bearing(to other: CLLocationCoordinate2D) -> CLLocationDirection {
        return CLLocationUtils.calculateBearing(
            from: (latitude: self.latitude, longitude: self.longitude),
            to: (latitude: other.latitude, longitude: other.longitude)
        )
    }
    
    /// Checks if this coordinate is valid (within acceptable latitude/longitude ranges).
    var isValid: Bool {
        return CLLocationUtils.isValidCoordinate(self)
    }
}