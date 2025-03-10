import Testing
import OpenCoreLocation

#if canImport(Contacts)
import Contacts
#endif

@Test func mainTest() async throws {
    _ = CLLocationManager()
}
