import Foundation
import Calagopus

struct AgentChatMessageImage: Identifiable, Hashable {
    let id: String
    let name: String
    let mediaType: String
    let url: String
    let byteSize: Int

    init?(_ json: CalagopusJSON) {
        guard let object = json.objectValue,
              let id = object["id"]?.stringValue,
              let url = object["url"]?.stringValue else {
            return nil
        }

        self.id = id
        name = object["name"]?.stringValue ?? "Image"
        mediaType = object["mediaType"]?.stringValue ?? "image/jpeg"
        self.url = url
        byteSize = object["byteSize"]?.intValue ?? 0
    }

    func loadData() async throws -> Data {
        let client = try CalagopusClientFactory.client()
        let endpoint = CalagopusEndpoint(
            operationID: "getAgentChatAttachment",
            method: .get,
            path: url
        )
        let response = try await client.response(for: endpoint)

        guard 200..<300 ~= response.statusCode else {
            throw CalagopusError.httpStatus(response.statusCode, response.body, response.error)
        }

        return response.body
    }
}
