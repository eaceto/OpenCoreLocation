import Foundation

#if canImport(Contacts)
import Contacts
#endif

// MARK: - CLPlacemark
/// A structure that contains placemark data for a given latitude and longitude.
/// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark)
open class CLPlacemark: NSObject, NSCopying, NSSecureCoding, @unchecked Sendable {

    // MARK: - Properties

    /// The location coordinate of the placemark.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/location)
    @NSCopying open private(set) var location: CLLocation?

    /// The associated region of the placemark, if applicable.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/region)
    @NSCopying open private(set) var region: CLRegion?

    /// The time zone associated with the placemark.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/timezone)
    open private(set) var timeZone: TimeZone?

    /// The name of the place, typically used to label a point of interest.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/name)
    open private(set) var name: String?

    /// The street address of the placemark (e.g., "1 Infinite Loop").
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/thoroughfare)
    open private(set) var thoroughfare: String?

    /// Additional street information (e.g., "Apt 4B").
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/subthoroughfare)
    open private(set) var subThoroughfare: String?

    /// The city or town of the placemark.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/locality)
    open private(set) var locality: String?

    /// The neighborhood or district of the placemark.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/sublocality)
    open private(set) var subLocality: String?

    /// The state, province, or administrative area of the placemark.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/administrativearea)
    open private(set) var administrativeArea: String?

    /// The county or second-level administrative area of the placemark.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/subadministrativearea)
    open private(set) var subAdministrativeArea: String?

    /// The postal code (ZIP code) of the placemark.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/postalcode)
    open private(set) var postalCode: String?

    /// The ISO country code of the placemark (e.g., "US", "GB").
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/isocountrycode)
    open private(set) var isoCountryCode: String?

    /// The full country name of the placemark.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/country)
    open private(set) var country: String?

    /// The name of the inland body of water associated with the placemark.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/inlandwater)
    open private(set) var inlandWater: String?

    /// The name of the ocean associated with the placemark.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/ocean)
    open private(set) var ocean: String?

    /// An array of areas of interest associated with the placemark.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/areasofinterest)
    open private(set) var areasOfInterest: [String]?

    /// A structured postal address representation of the placemark.
    /// Uses  `GenericPostalAddress` on non-Apple platforms.
    /// [Apple Documentation](https://developer.apple.com/documentation/corelocation/clplacemark/postaladdress)
    open private(set) var postalAddress: CNPostalAddress?

    // MARK: - Initializers

    /// Initializes a new placemark object.
    /// - Parameters:
    ///   - coordinate: The geographic coordinate of the placemark.
    ///   - name: The name of the place.
    ///   - locality: The city or town.
    ///   - administrativeArea: The state, province, or administrative area.
    ///   - country: The full country name.
    ///   - postalCode: The postal code.
    ///   - isoCountryCode: The ISO country code.
    public init(coordinate: CLLocationCoordinate2D, name: String? = nil,
                locality: String? = nil, administrativeArea: String? = nil,
                country: String? = nil, postalCode: String? = nil, isoCountryCode: String? = nil) {
        self.location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.name = name
        self.locality = locality
        self.administrativeArea = administrativeArea
        self.country = country
        self.postalCode = postalCode
        self.isoCountryCode = isoCountryCode?.uppercased()

#if canImport(Contacts)
        let mutableAddress = CNMutablePostalAddress()
        mutableAddress.street = name ?? ""
        mutableAddress.city = locality ?? ""
        mutableAddress.state = administrativeArea ?? ""
        mutableAddress.postalCode = postalCode ?? ""
        mutableAddress.country = country ?? ""
        mutableAddress.isoCountryCode = isoCountryCode?.uppercased() ?? ""
        self.postalAddress = mutableAddress
#else
        self.postalAddress = CNPostalAddress(
            street: name,
            city: locality,
            state: administrativeArea,
            country: country,
            postalCode: postalCode
        )
#endif
    }

    /// Copy initializer
    /// - Parameter placemark: The existing `CLPlacemark` to copy.
    public init(placemark: CLPlacemark) {
        self.location = placemark.location
        self.region = placemark.region
        self.timeZone = placemark.timeZone
        self.name = placemark.name
        self.thoroughfare = placemark.thoroughfare
        self.subThoroughfare = placemark.subThoroughfare
        self.locality = placemark.locality
        self.subLocality = placemark.subLocality
        self.administrativeArea = placemark.administrativeArea
        self.subAdministrativeArea = placemark.subAdministrativeArea
        self.postalCode = placemark.postalCode
        self.isoCountryCode = placemark.isoCountryCode
        self.country = placemark.country
        self.inlandWater = placemark.inlandWater
        self.ocean = placemark.ocean
        self.areasOfInterest = placemark.areasOfInterest
        self.postalAddress = placemark.postalAddress
    }

    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        return CLPlacemark(placemark: self)
    }

    // MARK: - NSSecureCoding
    public static var supportsSecureCoding: Bool { true }

    public func encode(with coder: NSCoder) {
        // Encode relevant properties
    }

    public required init?(coder: NSCoder) {
        // Decode properties
    }
}

#if !canImport(Contacts)
// MARK: - CNPostalAddress (Cross-Platform Alternative to Apple's CNPostalAddress)
/// A cross-platform struct to represent a postal address in a Linux-compatible way.
public struct CNPostalAddress: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let street: String?
    public let city: String?
    public let state: String?
    public let country: String?
    public let postalCode: String?

    public init(street: String? = nil, city: String? = nil, state: String? = nil,
                country: String? = nil, postalCode: String? = nil) {
        self.street = street
        self.city = city
        self.state = state
        self.country = country
        self.postalCode = postalCode
    }

    // MARK: - CustomStringConvertible
    public var description: String {
        var components: [String] = []
        if let street = street { components.append(street) }
        if let city = city { components.append(city) }
        if let state = state { components.append(state) }
        if let postalCode = postalCode { components.append(postalCode) }
        if let country = country { components.append(country) }
        return components.joined(separator: ", ")
    }

    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String {
        """
        CNPostalAddress(
            street: \(street ?? "nil"),
            city: \(city ?? "nil"),
            state: \(state ?? "nil"),
            postalCode: \(postalCode ?? "nil"),
            country: \(country ?? "nil")
        )
        """
    }
}
#endif
