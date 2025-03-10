import Foundation

// MARK: - CLLocationManagerService
/// Handles the business logic for CLLocationManager including accuracy-based provider selection and reactive location updates.
final class CLLocationManagerService {
    // MARK: - Errors
    enum Errors: Error {
        case noProviderForAccuracy
        case failedToUpdateLocation
    }

    // MARK: - Properties
    /// Mapping of accuracy types to location providers
    private var providers: [CLLocationAccuracy: any LocationProviderContract]
    private var currentProvider: (any LocationProviderContract)?

    /// Delegate to notify about location updates and errors
    weak var delegate: CLLocationManagerServiceDelegate?

    /// Timer for continuous location updates
    private var locationUpdateTimer: Timer?

    // MARK: - Initializer
    init() {
        // Initialize with the default provider for all accuracies
        let defaultProvider = LowAccuracyLocationProvider()
        self.providers = [
            kCLLocationAccuracyBest: defaultProvider,
            kCLLocationAccuracyNearestTenMeters: defaultProvider,
            kCLLocationAccuracyHundredMeters: defaultProvider,
            kCLLocationAccuracyKilometer: defaultProvider,
            kCLLocationAccuracyThreeKilometers: defaultProvider
        ]
    }

    // MARK: - Setup Methods
    /// Assigns a custom provider for a specific accuracy
    func setProvider(for accuracy: CLLocationAccuracy, provider: any LocationProviderContract) {
        providers[accuracy] = provider
    }

    // MARK: - One-Time Location Request
    /// Requests the user's location **once** (single update)
    /// - Apple Docs: ["Requests the one-time delivery of the user’s current location."](https://developer.apple.com/documentation/corelocation/cllocationmanager/requestlocation)
    func requestLocation(with accuracy: CLLocationAccuracy) async {
        do {
            guard let provider = providers[accuracy] else {
                delegate?.locationManagerService(self, didFailWithError: Errors.noProviderForAccuracy)
                return
            }
            let currentProviderId = currentProvider?.id

            if currentProviderId != provider.id {
                try await currentProvider?.stop()
                try await provider.start()
                currentProvider = provider
            }

            let location = try await provider.requestLocation()
            delegate?.locationManagerService(self, didUpdateLocation: location)
        } catch {
            delegate?.locationManagerService(self, didFailWithError: error)
        }
    }

    // MARK: - Continuous Location Updates
    func startUpdatingLocation(with accuracy: CLLocationAccuracy) {
        stopUpdatingLocation() // Ensure we clear any previous update cycles

        // Fetch provider for the accuracy level
        guard let provider = providers[accuracy] else {
            delegate?.locationManagerService(self, didFailWithError: Errors.noProviderForAccuracy)
            return
        }

        let interval = provider.poolInterval

        // Start the timer with the provider's pool interval
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                Task {
                    await self?.requestLocation(with: accuracy)
                }
            }
        }

        // Immediately request the first location update instead of waiting for the timer
        Task {
            await requestLocation(with: accuracy)
        }
    }

    func stopUpdatingLocation() {
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
    }
}

// MARK: - CLLocationManagerServiceDelegate
internal protocol CLLocationManagerServiceDelegate: AnyObject {
    func locationManagerService(_ service: CLLocationManagerService, didUpdateLocation location: SendableCLLocation)
    func locationManagerService(_ service: CLLocationManagerService, didFailWithError error: Error)
}
