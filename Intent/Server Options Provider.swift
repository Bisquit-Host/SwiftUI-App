import AppIntents

struct ServerOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        await Networking.fetchServers()
            .map(\.id)
    }
}
