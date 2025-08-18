import Foundation

// MARK: - CLError
/// Represents errors that can occur when using CoreLocation.
/// This struct conforms to `CustomNSError`, `Hashable`, and `Error`.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clerror)
public struct CLError: CustomNSError, Hashable, Error {

    /// The associated `NSError` instance.
    public let _nsError: NSError

    /// Initializes `CLError` from an `NSError` instance.
    /// - Parameter _nsError: An existing `NSError` instance.
    public init(_nsError: NSError) {
        self._nsError = _nsError
    }
    
    /// Initializes `CLError` from a `CLError.Code`.
    /// - Parameter code: The error code.
    public init(_ code: CLError.Code) {
        self._nsError = NSError(domain: CLError.errorDomain, code: code.rawValue, userInfo: nil)
    }

    // MARK: - Error Domain
    /// The error domain for CoreLocation errors.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clerror/2880277-errordomain)
    public static var errorDomain: String { "kCLErrorDomain" }

    // MARK: - CLError.Code
    /// Defines specific error codes that can occur within CoreLocation.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clerror/code)
    public enum Code: Int, @unchecked Sendable, Equatable {

        /// The location is unknown.
        case locationUnknown = 0

        /// The app is not authorized to use location services.
        case denied = 1

        /// A network error occurred.
        case network = 2

        /// The location manager failed to retrieve heading data.
        case headingFailure = 3

        /// Region monitoring is denied by the user.
        case regionMonitoringDenied = 4

        /// A failure occurred while monitoring a region.
        case regionMonitoringFailure = 5

        /// Region monitoring setup was delayed.
        case regionMonitoringSetupDelayed = 6

        /// Region monitoring response was delayed.
        case regionMonitoringResponseDelayed = 7

        /// No results were found for the geocode request.
        case geocodeFoundNoResult = 8

        /// A partial geocode result was found.
        case geocodeFoundPartialResult = 9

        /// The geocode request was canceled.
        case geocodeCanceled = 10

        /// Deferred location updates failed.
        case deferredFailed = 11

        /// Deferred updates were canceled because location updates were not occurring.
        case deferredNotUpdatingLocation = 12

        /// Deferred updates were canceled due to insufficient accuracy.
        case deferredAccuracyTooLow = 13

        /// Deferred updates were canceled because the distance filter was too small.
        case deferredDistanceFiltered = 14

        /// Deferred updates were canceled by the system.
        case deferredCanceled = 15

        /// Ranging is unavailable.
        case rangingUnavailable = 16

        /// Ranging failed.
        case rangingFailure = 17

        /// The user declined the location prompt.
        case promptDeclined = 18

        /// A historical location error occurred.
        case historicalLocationError = 19
    }

    // MARK: - Static Error Codes
    public static var locationUnknown: CLError.Code { .locationUnknown }
    public static var denied: CLError.Code { .denied }
    public static var network: CLError.Code { .network }
    public static var headingFailure: CLError.Code { .headingFailure }
    public static var regionMonitoringDenied: CLError.Code { .regionMonitoringDenied }
    public static var regionMonitoringFailure: CLError.Code { .regionMonitoringFailure }
    public static var regionMonitoringSetupDelayed: CLError.Code { .regionMonitoringSetupDelayed }
    public static var regionMonitoringResponseDelayed: CLError.Code { .regionMonitoringResponseDelayed }
    public static var geocodeFoundNoResult: CLError.Code { .geocodeFoundNoResult }
    public static var geocodeFoundPartialResult: CLError.Code { .geocodeFoundPartialResult }
    public static var geocodeCanceled: CLError.Code { .geocodeCanceled }
    public static var deferredFailed: CLError.Code { .deferredFailed }
    public static var deferredNotUpdatingLocation: CLError.Code { .deferredNotUpdatingLocation }
    public static var deferredAccuracyTooLow: CLError.Code { .deferredAccuracyTooLow }
    public static var deferredDistanceFiltered: CLError.Code { .deferredDistanceFiltered }
    public static var deferredCanceled: CLError.Code { .deferredCanceled }
    public static var rangingUnavailable: CLError.Code { .rangingUnavailable }
    public static var rangingFailure: CLError.Code { .rangingFailure }
    public static var promptDeclined: CLError.Code { .promptDeclined }
    public static var historicalLocationError: CLError.Code { .historicalLocationError }

    // MARK: - Alternate Region
    /// In a `regionMonitoringResponseDelayed` error, this property provides an alternative region that the location services can more effectively monitor.
    /// - Note: Unavailable in visionOS.
    @available(visionOS, unavailable)
    public var alternateRegion: CLRegion? { nil }
}
