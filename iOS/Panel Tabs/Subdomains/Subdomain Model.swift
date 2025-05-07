struct SubdomainResponse: Decodable {
    let limit: Int
    let domains: [Domain]
    let subdomains: [Subdomain]
}

struct Domain: Identifiable, Decodable {
    let id: Int
    let domain: String
}

struct Subdomain: Decodable, Equatable {
    let attributes: SubdomainAttributes
}

struct SubdomainAttributes: Identifiable, Decodable, Equatable {
    let id: Int
    let domain, subdomain: String
    let createdAt: String
}
