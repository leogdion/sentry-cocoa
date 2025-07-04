import SentryTestUtils
import XCTest

final class SentryExtraContextProviderTests: XCTestCase {

    private class Fixture {
        let crashWrapper = TestSentryCrashWrapper.sharedInstance()
#if os(iOS) || targetEnvironment(macCatalyst)
        let deviceWrapper = TestSentryUIDeviceWrapper()
#endif // os(iOS) || targetEnvironment(macCatalyst)
        let processWrapper = TestSentryNSProcessInfoWrapper()
        
        func getSut() -> SentryExtraContextProvider {
            #if os(iOS) || targetEnvironment(macCatalyst)
            return SentryExtraContextProvider(
                    crashWrapper: crashWrapper,
                    processInfoWrapper: processWrapper,
                    deviceWrapper: deviceWrapper)
            #else
            return SentryExtraContextProvider(
                    crashWrapper: crashWrapper,
                    processInfoWrapper: processWrapper)
            #endif // os(iOS) || targetEnvironment(macCatalyst)

        }
    }
    
    private var fixture: Fixture!
    
    override func setUp() {
        super.setUp()
        fixture = Fixture()
    }
    
    override func tearDown() {
        super.tearDown()
        clearTestState()
    }
    
    func testExtraCrashInfo() throws {
        let sut = fixture.getSut()
        fixture.crashWrapper.internalFreeMemorySize = 123_456
        fixture.crashWrapper.internalAppMemorySize = 234_567
        
        let actualContext = sut.getExtraContext()
        let device = actualContext["device"] as? [String: Any]
        let app = actualContext["app"] as? [String: Any]
        
        XCTAssertEqual(device?["free_memory"] as? UInt64, fixture.crashWrapper.internalFreeMemorySize)
        XCTAssertEqual(app?["app_memory"] as? UInt64, fixture.crashWrapper.internalAppMemorySize)
    }
    
    func testExtraDeviceInfo() throws {
#if os(iOS) || targetEnvironment(macCatalyst)
        let sut = fixture.getSut()
        fixture.deviceWrapper.internalOrientation = .landscapeLeft
        fixture.deviceWrapper.internalBatteryState = .full
        fixture.deviceWrapper.internalBatteryLevel = 0.44
        
        let actualContext = sut.getExtraContext()
        let device = actualContext["device"] as? [String: Any]
        
        XCTAssertEqual(device?["orientation"] as? String, "landscape")
        XCTAssertFalse(try XCTUnwrap(device?["charging"] as? Bool))
        XCTAssertEqual(device?["battery_level"] as? UInt, 44)
#endif // os(iOS) || targetEnvironment(macCatalyst)
    }
    
    func testExtraProcessInfo() throws {
        let sut = fixture.getSut()
        fixture.processWrapper.overrides.processorCount = 12
        fixture.processWrapper.overrides.thermalState = .critical

        let actualContext = sut.getExtraContext()
        let device = try XCTUnwrap(actualContext["device"] as? [String: Any])

        XCTAssertEqual(try XCTUnwrap(device["processor_count"] as? UInt), fixture.processWrapper.overrides.processorCount)
        XCTAssertEqual(try XCTUnwrap(device["thermal_state"] as? String), "critical")
    }

}
