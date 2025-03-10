import Foundation

/// A structure that contains the location information the framework delivers with each update.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/cllocationupdate)
public struct CLLocationUpdate {
    // MARK: - Location Information
    /// The user's location, if available.
    public var location: CLLocation?
    /// A Boolean value that indicates whether the user is stationary.
    public var isStationary: Bool

    // MARK: - Authorization and Service Status
    /// A Boolean value that indicates if location accuracy is limited.
    public var accuracyLimited: Bool
    /// A Boolean value that indicates if the authorization is denied.
    public var authorizationDenied: Bool
    /// A Boolean value that indicates if the authorization is denied globally (e.g., system-wide setting).
    public var authorizationDeniedGlobally: Bool
    /// A Boolean value that indicates if an authorization request is in progress.
    public var authorizationRequestInProgress: Bool
    /// A Boolean value that indicates if the authorization is restricted (e.g., parental controls).
    public var authorizationRestricted: Bool
    /// A Boolean value that indicates if the app is insufficiently authorized for the intended use.
    public var insufficientlyInUse: Bool
    /// A Boolean value that indicates if the location services are unavailable.
    public var locationUnavailable: Bool
    /// A Boolean value that indicates if a service session is required for the updates.
    public var serviceSessionRequired: Bool

    // MARK: - Initializer
    public init(location: CLLocation? = nil,
                isStationary: Bool = false,
                accuracyLimited: Bool = false,
                authorizationDenied: Bool = false,
                authorizationDeniedGlobally: Bool = false,
                authorizationRequestInProgress: Bool = false,
                authorizationRestricted: Bool = false,
                insufficientlyInUse: Bool = false,
                locationUnavailable: Bool = false,
                serviceSessionRequired: Bool = false) {
        self.location = location
        self.isStationary = isStationary
        self.accuracyLimited = accuracyLimited
        self.authorizationDenied = authorizationDenied
        self.authorizationDeniedGlobally = authorizationDeniedGlobally
        self.authorizationRequestInProgress = authorizationRequestInProgress
        self.authorizationRestricted = authorizationRestricted
        self.insufficientlyInUse = insufficientlyInUse
        self.locationUnavailable = locationUnavailable
        self.serviceSessionRequired = serviceSessionRequired
    }
}
