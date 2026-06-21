import SwiftUI
import Calagopus

@Observable
final class ConsoleVM {
    private let id: String

    init(_ id: String) {
        self.id = id
    }

    var alertKill = false
    var inspectorPresented = false
    var commandHistoryPresented = false
    var commandHistory: [ConsoleCommandSnippet] = []
    var commandHistoryLoading = false
    var command = ""
    var fontSize = 10.0
    var lastMessageIndex = 0

    func returnFontDesignName(_ fontDesign: Font.Design) -> String {
        switch fontDesign {
        case .default:    "Default"
        case .serif:      "Serif"
        case .rounded:    "Rounded"
        case .monospaced: "Monospaced"
        default:          ""
        }
    }

    func sendCommand() async {
        await CalagopusNet.sendCommand(id, command: command)
        command = ""
    }

    func useHistoryCommand(_ command: String) {
        self.command = command
        commandHistoryPresented = false
    }

    func fetchCommandHistory() async {
        commandHistoryLoading = true
        defer {
            commandHistoryLoading = false
        }

        do {
            let client = try CalagopusClientFactory.client()
            let endpoint = try CalagopusGeneratedOperations.getApiClientServersServerActivity.endpoint(
                pathValues: ["server": id],
                queryValues: [
                    "page": "1",
                    "per_page": "25",
                    "search": "server:console.command",
                ]
            )
            commandHistory = ConsoleCommandSnippet.snippets(from: try await client.sendJSON(endpoint))
        } catch {
            SystemAlert.error(error)
        }
    }
}
