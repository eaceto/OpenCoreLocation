import Foundation

#if canImport(Contacts)
import Contacts
#endif

public typealias CLGeocodeCompletionHandler = ([CLPlacemark]?, (any Error)?) -> Void

/// An object that provides services for converting between a coordinate and user-friendly location information.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder)
open class CLGeocoder: NSObject {

    // MARK: - Properties
    /// A Boolean value indicating whether the geocoder is actively processing a request.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder/isgeocoding)
    open var isGeocoding: Bool {
        implementation.isGeocoding
    }

    /// The geocoding implementation used internally.
    private let implementation: CLGeocoderImplementationContract

    // MARK: - Initialization
    /// Creates a geocoder instance for converting between geographic coordinates and user-friendly location information.
    /// - Parameter implementation: The geocoding implementation to use. Defaults to `OpenStreetMapGeocoder`.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder/init)
    public override init() {
        self.implementation = OpenStreetMapGeocoder()
    }

    // MARK: - Forward Geocoding (Address → Coordinates)
    /// Initiates a forward geocoding request to convert an address into one or more locations.
    /// - Parameters:
    ///   - addressString: The address string to geocode.
    ///   - completionHandler: A closure that receives an array of `CLPlacemark` objects or an error.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder/geocodeaddressstring(_:completionhandler:))
    open func geocodeAddressString(_ addressString: String, completionHandler: @escaping CLGeocodeCompletionHandler) {
        Task {
            do {
                let results = try await implementation.geocodeAddressString(addressString, in: nil, preferredLocale: nil)
                DispatchQueue.main.async { completionHandler(results, nil) }
            } catch {
                DispatchQueue.main.async { completionHandler(nil, error) }
            }
        }
    }

    /// Initiates an asynchronous forward geocoding request.
    /// - Parameter addressString: The address string to geocode.
    /// - Returns: An array of `CLPlacemark` objects.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder/geocodeaddressstring(_:))
    open func geocodeAddressString(_ addressString: String) async throws -> [CLPlacemark] {
        return try await implementation.geocodeAddressString(addressString, in: nil, preferredLocale: nil)
    }

    /// Initiates a forward geocoding request with a search region constraint.
    /// - Parameters:
    ///   - addressString: The address string to geocode.
    ///   - region: The `CLRegion` within which to search.
    ///   - completionHandler: A closure that receives an array of `CLPlacemark` objects or an error.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder/geocodeaddressstring(_:in:completionhandler:))
    open func geocodeAddressString(_ addressString: String, in region: CLRegion?, completionHandler: @escaping CLGeocodeCompletionHandler) {
        Task {
            do {
                let results = try await implementation.geocodeAddressString(addressString, in: region, preferredLocale: nil)
                DispatchQueue.main.async { completionHandler(results, nil) }
            } catch {
                DispatchQueue.main.async { completionHandler(nil, error) }
            }
        }
    }

    /// Initiates an asynchronous forward geocoding request with a search region constraint.
    /// - Parameters:
    ///   - addressString: The address string to geocode.
    ///   - region: The `CLRegion` within which to search.
    /// - Returns: An array of `CLPlacemark` objects.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder/geocodeaddressstring(_:in:))
    open func geocodeAddressString(_ addressString: String, in region: CLRegion?) async throws -> [CLPlacemark] {
        return try await implementation.geocodeAddressString(addressString, in: region, preferredLocale: nil)
    }

    // MARK: - Reverse Geocoding (Coordinates → Address)
    /// Initiates a reverse geocoding request to convert a coordinate into user-friendly location information.
    /// - Parameters:
    ///   - location: The `CLLocation` object containing the latitude and longitude.
    ///   - completionHandler: A closure that receives an array of `CLPlacemark` objects or an error.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder/reversegeocodelocation(_:completionhandler:))
    open func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
        Task {
            do {
                let results = try await implementation.reverseGeocodeLocation(location, preferredLocale: nil)
                DispatchQueue.main.async { completionHandler(results, nil) }
            } catch {
                DispatchQueue.main.async { completionHandler(nil, error) }
            }
        }
    }

    /// Initiates an asynchronous reverse geocoding request.
    /// - Parameter location: The `CLLocation` object containing the latitude and longitude.
    /// - Returns: An array of `CLPlacemark` objects.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder/reversegeocodelocation(_:))
    open func reverseGeocodeLocation(_ location: CLLocation) async throws -> [CLPlacemark] {
        return try await implementation.reverseGeocodeLocation(location, preferredLocale: nil)
    }

    // MARK: - Cancel Requests
    /// Cancels all pending geocoding requests.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder/cancelgeocode)
    open func cancelGeocode() {
        implementation.cancelGeocode()
    }

    // MARK: - Postal Address Geocoding (Postal Address → Coordinates)
    /// Initiates a geocoding request to convert a postal address into coordinates.
    /// - Parameters:
    ///   - postalAddress: The `CNPostalAddress` object containing address details.
    ///   - completionHandler: A closure that receives an array of `CLPlacemark` objects or an error.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder/geocodepostaladdress(_:completionhandler:))
    open func geocodePostalAddress(_ postalAddress: CNPostalAddress, completionHandler: @escaping CLGeocodeCompletionHandler) {
        Task {
            do {
                let results = try await implementation.geocodePostalAddress(postalAddress, preferredLocale: nil)
                DispatchQueue.main.async { completionHandler(results, nil) }
            } catch {
                DispatchQueue.main.async { completionHandler(nil, error) }
            }
        }
    }

    /// Initiates an asynchronous geocoding request for a postal address.
    /// - Parameter postalAddress: The `CNPostalAddress` object containing address details.
    /// - Returns: An array of `CLPlacemark` objects.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clgeocoder/geocodepostaladdress(_:))
    open func geocodePostalAddress(_ postalAddress: CNPostalAddress) async throws -> [CLPlacemark] {
        return try await implementation.geocodePostalAddress(postalAddress, preferredLocale: nil)
    }
}
