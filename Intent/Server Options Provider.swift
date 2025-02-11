import AppIntents

struct ServerOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        do {
            return try await Networking.fetchServers().map(\.id)
        } catch {
            return []
        }
    }
}
