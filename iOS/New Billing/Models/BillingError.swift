struct ProblemDetails: Decodable {
    let type: String
    let title: String
    let status: Int
    let detail: String?
    let instance: String?
    let errors: [String: String]?
}
