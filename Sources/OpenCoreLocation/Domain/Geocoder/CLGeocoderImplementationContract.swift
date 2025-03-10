import Foundation

#if canImport(Contacts)
import Contacts
#endif

/// Defines the interface that geocoding services must implement.
public protocol CLGeocoderImplementationContract: AnyObject {

    // MARK: - Properties
    /// Indicates whether the geocoder is currently processing a request.
    var isGeocoding: Bool { get }

    // MARK: - Forward Geocoding (Address → Coordinates)
    /// Converts an address string into a list of placemarks asynchronously.
    func geocodeAddressString(_ addressString: String, in region: CLRegion?, preferredLocale locale: Locale?) async throws -> [CLPlacemark]

    // MARK: - Reverse Geocoding (Coordinates → Address)
    /// Converts a location into a human-readable address asynchronously.
    func reverseGeocodeLocation(_ location: CLLocation, preferredLocale locale: Locale?) async throws -> [CLPlacemark]

    // MARK: - Postal Address Geocoding (Postal Address → Coordinates)
    func geocodePostalAddress(_ postalAddress: CNPostalAddress, preferredLocale locale: Locale?) async throws -> [CLPlacemark]

    // MARK: - Cancel Requests
    /// Cancels any ongoing geocoding requests.
    func cancelGeocode()
}
