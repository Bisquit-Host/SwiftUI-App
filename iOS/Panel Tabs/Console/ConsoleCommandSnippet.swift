import Calagopus

struct ConsoleCommandSnippet: Identifiable, Hashable {
    let id: String
    let name: String
    let command: String
    let created: String?

    init?(_ json: CalagopusJSON) {
        guard
            let object = json.objectValue,
            object["event"]?.stringValue == "server:console.command",
            let command = object["data"]?.objectValue?["command"]?.stringValue,
            command.isEmpty == false
        else { return nil }

        let username = object["user"]?.objectValue?["username"]?.stringValue
        let created = object["created"]?.stringValue

        self.id = [created, username, command].compactMap(\.self).joined(separator: "|")
        self.name = username ?? "Console Command"
        self.command = command
        self.created = created
    }

    static func snippets(from json: CalagopusJSON) -> [ConsoleCommandSnippet] {
        let object = json.objectValue ?? [:]
        let data = object["activities"]?.objectValue?["data"]?.arrayValue ?? []

        return data.compactMap(ConsoleCommandSnippet.init)
    }
}
