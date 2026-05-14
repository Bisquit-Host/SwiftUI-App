import Testing

#if !os(macOS)
@testable import Bisquit_Host

struct UpdateCheckerTests {
    @Test func `Update checker compares numeric versions correctly`() {
        let cases: [(current: String, appStore: String, expectsUpdate: Bool)] = [
            (current: "1.2.3", appStore: "1.2.4", expectsUpdate: true),
            (current: "1.2.10", appStore: "1.2.2", expectsUpdate: false),
            (current: "2.0", appStore: "2.0.0", expectsUpdate: false),
            (current: "0.9.9", appStore: "1.0", expectsUpdate: true)
        ]
        
        for testCase in cases {
            let result = AppStoreUpdateLookup.isUpdateAvailable(
                currentVersion: testCase.current,
                appStoreVersion: testCase.appStore
            )

            #expect(
                result == testCase.expectsUpdate,
                "current=\(testCase.current) appStore=\(testCase.appStore) expected=\(testCase.expectsUpdate) got=\(result)"
            )
        }
    }
}
#endif
