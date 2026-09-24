import Foundation
import Calagopus

@Observable
final class StartupVM {
    private let id: String

    init(_ id: String) {
        self.id = id
    }

    private(set) var startupCommand = ""
    private(set) var rawStartupCommand = ""
    private(set) var startupVariables: [CalagopusServerVariable] = []
    private(set) var dockerImages: [String: String] = [:]

    var sortedDockerImages: [(key: String, value: String)] {
        Array(dockerImages)
            .sorted {
                guard
                    let firstKeyNumber = $0.key.split(separator: " ").last.flatMap({ Double($0) }),
                    let secondKeyNumber = $1.key.split(separator: " ").last.flatMap({ Double($0) })
                else {
                    return false
                }

                return firstKeyNumber > secondKeyNumber
            }
    }

    func fetchStartupVariables() async {
        do {
            try await refreshStartupVariables()
        } catch {
            SystemAlert.error(error)
        }
    }

    private func refreshStartupVariables() async throws {
        async let variables = CalagopusNet.client().startupVariables(server: id)
        async let serverDetails = CalagopusNet.client().server(id: id)

        let (startupVariables, details) = try await (variables, serverDetails)

        self.startupVariables = startupVariables
        startupCommand = details.startup
        rawStartupCommand = details.startup

        if let dockerImages = details.egg.dockerImages {
            self.dockerImages = dockerImages
        }
    }

    func updateVariable(key: String, value: String) async -> CalagopusServerVariable? {
        do {
            try await CalagopusNet.client().updateStartupVariable(server: id, key: key, value: value)
            try await refreshStartupVariables()
            return startupVariables.first { $0.envVariable == key }
        } catch {
            SystemAlert.error(error)
            return nil
        }
    }

    func updateDockerImage(_ newImage: String) async {
        do {
            try await CalagopusNet.client().updateDockerImage(server: id, image: newImage)
            SystemAlert.done("Docker image updated")
        } catch {
            SystemAlert.error(error)
        }
    }
}
