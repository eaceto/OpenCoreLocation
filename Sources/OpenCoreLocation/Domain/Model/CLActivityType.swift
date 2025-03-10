import Foundation

/// The type of user activity associated with the location updates.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clactivitytype)
public enum CLActivityType: String {
    /// The location is not associated with a specific activity.
    case other = "Other"
    /// The location is associated with automotive navigation.
    case automotiveNavigation = "Automotive Navigation"
    /// The location is associated with fitness activities such as walking or running.
    case fitness = "Fitness"
    /// The location is associated with navigation that is not automotive.
    case otherNavigation = "Other Navigation"
}
