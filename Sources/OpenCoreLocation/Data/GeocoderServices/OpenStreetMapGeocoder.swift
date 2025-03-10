import Foundation

#if canImport(Contacts)
import Contacts
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A geocoder that fetches location data from OpenStreetMap's Nominatim API.
final class OpenStreetMapGeocoder: CLGeocoderImplementationContract {

    // MARK: - Properties
    /// Indicates whether the geocoder is currently processing a request.
    private(set) var isGeocoding: Bool = false

    /// The URL session used for geocoding requests.
    let session: URLSession

    /// The base URL for forward geocoding.
    let geocodeBaseURL = "https://nominatim.openstreetmap.org/search"

    /// The base URL for reverse geocoding.
    let reverseGeocodeBaseURL = "https://nominatim.openstreetmap.org/reverse"

    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Forward Geocoding (Address → Coordinates)
    func geocodeAddressString(_ addressString: String, in region: CLRegion?, preferredLocale locale: Locale?) async throws -> [CLPlacemark] {
        guard let encodedAddress = addressString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(geocodeBaseURL)?q=\(encodedAddress)&format=json") else {
            throw CLError(_nsError: NSError(domain: CLError.errorDomain, code: CLError.geocodeFoundNoResult.rawValue, userInfo: nil))
        }

        isGeocoding = true
        defer { isGeocoding = false }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw CLError(_nsError: NSError(domain: CLError.errorDomain, code: CLError.network.rawValue, userInfo: nil))
        }

        let placemarks = try JSONDecoder().decode([OSMGeocodeResult].self, from: data)
        return placemarks.map { $0.toPlacemark() }
    }

    // MARK: - Reverse Geocoding (Coordinates → Address)
    func reverseGeocodeLocation(_ location: CLLocation, preferredLocale locale: Locale?) async throws -> [CLPlacemark] {
        let urlString = "\(reverseGeocodeBaseURL)?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&format=json"

        guard let url = URL(string: urlString) else {
            throw CLError(_nsError: NSError(domain: CLError.errorDomain, code: CLError.geocodeFoundNoResult.rawValue, userInfo: nil))
        }

        isGeocoding = true
        defer { isGeocoding = false }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw CLError(_nsError: NSError(domain: CLError.errorDomain, code: CLError.network.rawValue, userInfo: nil))
        }

        let result = try JSONDecoder().decode(OSMReverseGeocodeResult.self, from: data)
        return [result.toPlacemark()]
    }

    // MARK: - Postal Address Geocoding (Postal Address → Coordinates)
    func geocodePostalAddress(_ postalAddress: CNPostalAddress, preferredLocale locale: Locale?) async throws -> [CLPlacemark] {
        let addressComponents = [
            postalAddress.street,
            postalAddress.city,
            postalAddress.state,
            postalAddress.postalCode,
            postalAddress.country
        ].compactMap { $0 }.joined(separator: ", ")

        return try await geocodeAddressString(addressComponents, in: nil, preferredLocale: locale)
    }

    // MARK: - Cancelling Requests
    func cancelGeocode() {
        isGeocoding = false
    }
}

// MARK: - OpenStreetMap Response Model
/// Represents a result from the OpenStreetMap Nominatim API.
private struct OSMGeocodeResult: Codable {
    let lat: String
    let lon: String
    let display_name: String

    func toPlacemark() -> CLPlacemark {
        return CLPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: Double(lat) ?? 0.0, longitude: Double(lon) ?? 0.0),
            name: display_name
        )
    }
}

/// Represents a reverse geocoding result from the OpenStreetMap API.
struct OSMReverseGeocodeResult: Codable {
    let lat: String
    let lon: String
    let display_name: String
    let address: OSMAddress?

    func toPlacemark() -> CLPlacemark {
        return CLPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: Double(lat) ?? 0.0, longitude: Double(lon) ?? 0.0),
            name: display_name,
            locality: address?.city,
            administrativeArea: address?.state,
            country: address?.country,
            postalCode: address?.postcode,
            isoCountryCode: address?.country_code
        )
    }
}

/// Represents the structured address in OpenStreetMap.
struct OSMAddress: Codable {
    let road: String?
    let city: String?
    let town: String?
    let village: String?
    let state: String?
    let country: String?
    let postcode: String?
    let country_code: String?
}
