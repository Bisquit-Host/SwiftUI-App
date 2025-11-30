import AppIntents

struct ServerIntentTypeAppEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Server")
    static let defaultQuery = ServerIntentTypeAppEntityQuery()

    var id: String
    var displayString: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: displayString),
            subtitle: LocalizedStringResource(stringLiteral: id)
        )
    }

    init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }

    struct ServerIntentTypeAppEntityQuery: EntityQuery {
        func entities(for identifiers: [ServerIntentTypeAppEntity.ID]) async throws -> [ServerIntentTypeAppEntity] {
            let servers = await Networking.fetchServers()
            let serversById = Dictionary(uniqueKeysWithValues: servers.map { ($0.id, $0) })

            return identifiers.map { id in
                if let server = serversById[id] {
                    return ServerIntentTypeAppEntity(id: server.id, displayString: server.name)
                }

                return ServerIntentTypeAppEntity(id: id, displayString: id)
            }
        }

        func suggestedEntities() async throws -> [ServerIntentTypeAppEntity] {
            await Networking.fetchServers().map {
                ServerIntentTypeAppEntity(id: $0.id, displayString: $0.name)
            }
        }
    }
}
