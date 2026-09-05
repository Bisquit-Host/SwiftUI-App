struct AgentChatMessageRequest: Encodable {
    let message: String
    let images: [AgentChatImageInput]
    let server: String?
}
