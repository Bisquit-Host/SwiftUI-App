struct AgentChatAnswerRequest: Encodable {
    let kind: String
    let answers: [AgentQuestionAnswer]?
    let message: String?
    
    static func answers(_ answers: [AgentQuestionAnswer]) -> Self {
        Self(kind: "answers", answers: answers, message: nil)
    }
    
    static func message(_ message: String) -> Self {
        Self(kind: "message", answers: nil, message: message)
    }
    
    static let skip = Self(kind: "skip", answers: nil, message: nil)
}
