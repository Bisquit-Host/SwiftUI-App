struct AgentQuestionAnswer: Encodable, Hashable {
    var selected: [String] = []
    var other = ""
    
    var isEmpty: Bool {
        selected.isEmpty && other.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private enum CodingKeys: String, CodingKey {
        case selected, other
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selected, forKey: .selected)
        
        let trimmedOther = other.trimmingCharacters(in: .whitespacesAndNewlines)
        try container.encodeIfPresent(trimmedOther.isEmpty ? nil : trimmedOther, forKey: .other)
    }
}
