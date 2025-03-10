import Foundation

// MARK: - Type Aliases
/// Represents latitude or longitude values in degrees.
public typealias CLLocationDegrees = Double

/// Represents the accuracy of location data in meters.
public typealias CLLocationAccuracy = Double

/// Represents a distance in meters.
public typealias CLLocationDistance = Double

/// Represents speed in meters per second.
public typealias CLLocationSpeed = Double

/// Represents the accuracy of a speed measurement in meters per second.
public typealias CLLocationSpeedAccuracy = Double

/// Represents a direction in degrees.
public typealias CLLocationDirection = Double

/// Represents the accuracy of a directional measurement in degrees.
public typealias CLLocationDirectionAccuracy = Double

// MARK: - CLLocation Accuracy Constants
/// A value that indicates no distance filtering.
public let kCLDistanceFilterNone: CLLocationDistance = -1.0

/// The highest possible accuracy, intended for precise positioning.
@available(macOS 10.7, *)
public let kCLLocationAccuracyBestForNavigation: CLLocationAccuracy = 0.1

/// The highest possible accuracy that can be achieved under normal conditions.
public let kCLLocationAccuracyBest: CLLocationAccuracy = 1.0

/// The accuracy within 10 meters.
public let kCLLocationAccuracyNearestTenMeters: CLLocationAccuracy = 10.0

/// The accuracy within 100 meters.
public let kCLLocationAccuracyHundredMeters: CLLocationAccuracy = 100.0

/// The accuracy within 1 kilometer.
public let kCLLocationAccuracyKilometer: CLLocationAccuracy = 1000.0

/// The accuracy within 3 kilometers.
public let kCLLocationAccuracyThreeKilometers: CLLocationAccuracy = 3000.0

/// Represents reduced accuracy mode (Apple’s privacy-preserving mode).
@available(macOS 11.0, *)
public let kCLLocationAccuracyReduced: CLLocationAccuracy = 300.0
