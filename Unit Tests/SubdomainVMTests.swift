import Testing

@testable import Bisquit_Host

struct SubdomainVMTests {
    @Test func `accepts 1.1 subdomain names`() {
        let viewModel = SubdomainVM("")

        for subdomain in ["abc", "A1b", String(repeating: "a", count: 32)] {
            viewModel.subdomain = subdomain
            #expect(viewModel.isSubdomainValid)
        }
    }

    @Test func `rejects invalid 1.1 subdomain names`() {
        let viewModel = SubdomainVM("")
        let invalidSubdomains = [
            "",
            "ab",
            String(repeating: "a", count: 33),
            "game-server",
            "game_server",
            "gáme"
        ]

        for subdomain in invalidSubdomains {
            viewModel.subdomain = subdomain
            #expect(!viewModel.isSubdomainValid)
        }
    }
}
