import Foundation
import Testing

@testable import Bisquit_Host

struct SystemAlertTests {
    @Test func `task and URL session cancellation are ignored`() {
        #expect(SystemAlert.isCancellation(CancellationError()))
        #expect(SystemAlert.isCancellation(URLError(.cancelled)))
        #expect(SystemAlert.isCancellation(NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled)))
    }

    @Test func `network failures and unrelated error codes are preserved`() {
        #expect(!SystemAlert.isCancellation(URLError(.timedOut)))
        #expect(!SystemAlert.isCancellation(URLError(.notConnectedToInternet)))
        #expect(!SystemAlert.isCancellation(NSError(domain: "OtherErrorDomain", code: NSURLErrorCancelled)))
    }
}
