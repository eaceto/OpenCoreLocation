import XCTest
@testable import OpenCoreLocation

final class OpenCoreLocationModelTests: XCTestCase {
    // MARK: - CLAuthorizationStatus Tests
    func testCLAuthorizationStatus() {
        let expectedValues: [CLAuthorizationStatus: String] = [
            .notDetermined: "Not Determined",
            .restricted: "Restricted",
            .denied: "Denied",
            .authorizedWhenInUse: "Authorized When In Use",
            .authorizedAlways: "Authorized Always"
        ]
        for (status, expectedValue) in expectedValues {
            XCTAssertEqual(status.rawValue, expectedValue)
        }
    }

    // MARK: - CLActivityType Tests
    func testCLActivityType() {
        let expectedValues: [CLActivityType: String] = [
            .other: "Other",
            .automotiveNavigation: "Automotive Navigation",
            .fitness: "Fitness",
            .otherNavigation: "Other Navigation"
        ]
        for (activityType, expectedValue) in expectedValues {
            XCTAssertEqual(activityType.rawValue, expectedValue)
        }
    }

    // MARK: - CLAccuracyAuthorization Tests
    func testCLAccuracyAuthorization() {
        let expectedValues: [CLAccuracyAuthorization: String] = [
            .fullAccuracy: "Full Accuracy",
            .reducedAccuracy: "Reduced Accuracy"
        ]
        for (accuracy, expectedValue) in expectedValues {
            XCTAssertEqual(accuracy.rawValue, expectedValue)
        }
    }

    // MARK: - CLLocationAccuracy Tests
    func testCLLocationAccuracy() {
        let expectedValues: [CLLocationAccuracy: Double] = [
            kCLLocationAccuracyBest: 1.0,
            kCLLocationAccuracyNearestTenMeters: 10.0,
            kCLLocationAccuracyHundredMeters: 100.0,
            kCLLocationAccuracyKilometer: 1000.0,
            kCLLocationAccuracyThreeKilometers: 3000.0
        ]
        for (accuracy, expectedValue) in expectedValues {
            XCTAssertEqual(accuracy, expectedValue)
        }
    }

    // MARK: - CLDistanceFilter Tests
    func testCLDistanceFilter() {
        let expectedValues: [CLDistanceFilter: Double] = [
            .none: 0.0,
            .tenMeters: 10.0,
            .fiftyMeters: 50.0,
            .hundredMeters: 100.0
        ]
        for (filter, expectedValue) in expectedValues {
            XCTAssertEqual(filter.rawValue, expectedValue)
        }
    }

    // MARK: - CLLocationManagerHeadingFilter Tests
    func testCLLocationManagerHeadingFilter() {
        let expectedValues: [CLLocationManagerHeadingFilter: Double] = [
            .none: 0.0,
            .fiveDegrees: 5.0,
            .tenDegrees: 10.0,
            .fifteenDegrees: 15.0
        ]
        for (filter, expectedValue) in expectedValues {
            XCTAssertEqual(filter.rawValue, expectedValue)
        }
    }

    // MARK: - CLHeadingComponent Tests
    func testCLHeadingComponent() {
        let expectedValues: [CLHeadingComponent: String] = [
            .magneticHeading: "Magnetic Heading",
            .trueHeading: "True Heading",
            .headingAccuracy: "Heading Accuracy"
        ]
        for (component, expectedValue) in expectedValues {
            XCTAssertEqual(component.rawValue, expectedValue)
        }
    }

    // MARK: - CLProximity Tests
    func testCLProximity() {
        let expectedValues: [CLProximity: String] = [
            .unknown: "Unknown",
            .immediate: "Immediate",
            .near: "Near",
            .far: "Far"
        ]
        for (proximity, expectedValue) in expectedValues {
            XCTAssertEqual(proximity.rawValue, expectedValue)
        }
    }

    // MARK: - CLRegionState Tests
    func testCLRegionState() {
        let expectedValues: [CLRegionState: String] = [
            .unknown: "Unknown",
            .inside: "Inside",
            .outside: "Outside"
        ]
        for (state, expectedValue) in expectedValues {
            XCTAssertEqual(state.rawValue, expectedValue)
        }
    }
}
