public struct WWResourceUsageResponse: Codable {
    public let attributes: WWResourceUsageAttributes
}

public struct WWResourceUsageAttributes: Codable {
    public let current_state: String
}
