import Foundation
import Testing

@testable import Bisquit_Host

struct AdminTicketURLTests {
    @Test(arguments: [
        "https://my.bisquit.host/admin/support/42",
        "https://test-my.bisquit.host/admin/support/42/",
        "https://my.bisquit.host/admin/support/42?source=email#messages"
    ])
    func acceptsAdminTicketLinks(_ value: String) throws {
        let url = try #require(URL(string: value))
        #expect(AdminTicketURL.ticketID(from: url) == 42)
    }

    @Test(arguments: [
        "http://my.bisquit.host/admin/support/42",
        "https://my.bisquit.host.example.com/admin/support/42",
        "https://user@my.bisquit.host/admin/support/42",
        "https://my.bisquit.host:8000/admin/support/42",
        "https://my.bisquit.host/support/42",
        "https://my.bisquit.host/admin/support",
        "https://my.bisquit.host/admin/support/0",
        "https://my.bisquit.host/admin/support/-1",
        "https://my.bisquit.host/admin/support/abc",
        "https://my.bisquit.host/admin/support/999999999999999999999999",
        "https://my.bisquit.host/admin/support/42/reply",
        "https://my.bisquit.host/admin//support/42"
    ])
    func rejectsInvalidTicketLinks(_ value: String) throws {
        let url = try #require(URL(string: value))
        #expect(AdminTicketURL.ticketID(from: url) == nil)
    }
}
