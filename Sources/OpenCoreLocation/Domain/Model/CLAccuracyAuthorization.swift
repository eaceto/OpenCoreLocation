import Foundation

// MARK: - CLAccuracyAuthorization
/// The accuracy level the app is authorized to use.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/claccuracyauthorization)
public enum CLAccuracyAuthorization: String, CustomDebugStringConvertible, CustomStringConvertible {
    /// The app can access location data with full accuracy.
    case fullAccuracy = "Full Accuracy"
    /// The app can access location data only with reduced accuracy.
    case reducedAccuracy = "Reduced Accuracy"

    // MARK: - CustomStringConvertible
    /// A user-friendly description of the accuracy authorization.
    public var description: String {
        switch self {
        case .fullAccuracy:
            return "CLAccuracyAuthorization(fullAccuracy)"
        case .reducedAccuracy:
            return "CLAccuracyAuthorization(reducedAccuracy)"
        }
    }

    // MARK: - CustomDebugStringConvertible
    /// A debug-friendly description of the accuracy authorization.
    public var debugDescription: String {
        return description
    }
}
