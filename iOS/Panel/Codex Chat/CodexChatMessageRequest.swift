struct CodexChatMessageRequest: Encodable {
    let message: String
    let images: [CodexChatImageInput]
    let server: String?
}
