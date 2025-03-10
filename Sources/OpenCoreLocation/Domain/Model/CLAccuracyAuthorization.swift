import Foundation

// MARK: - CLAccuracyAuthorization
/// The accuracy level the app is authorized to use.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/claccuracyauthorization)
public enum CLAccuracyAuthorization: String {
    /// The app can access location data with full accuracy.
    case fullAccuracy = "Full Accuracy"
    /// The app can access location data only with reduced accuracy.
    case reducedAccuracy = "Reduced Accuracy"
}
