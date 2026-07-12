import Foundation
import Testing

@testable import Bisquit_Host

struct PanelSignInURLTests {
    @Test func `accepts production authorization link`() throws {
        let url = try #require(
            URL(string: "https://my.bisquit.host/oidc/authorize?request_id=request-123"))

        #expect(PanelSignInURL.requestID(from: url) == "request-123")
    }

    @Test func `accepts test authorization link`() throws {
        let url = try #require(
            URL(string: "https://test-my.bisquit.host/oidc/authorize?request_id=test-request"))

        #expect(PanelSignInURL.requestID(from: url) == "test-request")
    }

    @Test func `accepts custom scheme authorization link`() throws {
        let url = try #require(URL(string: "bisq://oidc/authorize?request_id=custom-request"))

        #expect(PanelSignInURL.requestID(from: url) == "custom-request")
    }

    @Test func `rejects spoofed billing host`() throws {
        let url = try #require(
            URL(string: "https://my.bisquit.host.example.com/oidc/authorize?request_id=request-123"))

        #expect(PanelSignInURL.requestID(from: url) == nil)
    }

    @Test func `rejects missing request id`() throws {
        let url = try #require(URL(string: "https://my.bisquit.host/oidc/authorize"))

        #expect(PanelSignInURL.requestID(from: url) == nil)
    }

    @Test func `rejects unrelated universal link`() throws {
        let url = try #require(URL(string: "https://my.bisquit.host/auth?request_id=request-123"))

        #expect(PanelSignInURL.requestID(from: url) == nil)
    }
}
