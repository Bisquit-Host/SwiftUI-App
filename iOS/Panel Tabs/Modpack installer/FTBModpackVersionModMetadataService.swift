import Foundation

actor FTBModpackVersionModMetadataService {
    static let shared = FTBModpackVersionModMetadataService()
    
    private struct MetadataCacheEntry {
        let metadata: FTBModpackVersionModMetadata
        let createdAt: Date
    }
    
    private struct ProjectCacheEntry {
        let payload: ModrinthProjectPayload
        let createdAt: Date
    }
    
    private struct AuthorCacheEntry {
        let authors: [FTBModpackAuthor]
        let createdAt: Date
    }
    
    private var metadataByHash: [String: MetadataCacheEntry] = [:]
    private var projectById: [String: ProjectCacheEntry] = [:]
    private var authorsByProjectId: [String: AuthorCacheEntry] = [:]
    private var usernameById: [String: String] = [:]
    private let cacheTTL: TimeInterval = 60 * 60
    
    func fetchMetadata(for mod: FTBModpackVersionMod) async -> FTBModpackVersionModMetadata? {
        guard let sha1 = normalizedHash(mod.sha1) else {
            return nil
        }
        
        if let cached = metadataByHash[sha1], Date().timeIntervalSince(cached.createdAt) < cacheTTL {
            return cached.metadata
        }
        
        do {
            let versionPayload = try await fetchVersionPayload(hash: sha1)
            guard let projectId = versionPayload.projectId else {
                return nil
            }
            
            let projectPayload = try await fetchProjectPayload(projectId: projectId)
            let authors = try await fetchAuthors(
                projectId: projectId,
                fallbackAuthorId: versionPayload.authorId
            )
            
            let metadata = FTBModpackVersionModMetadata(
                displayName: normalizedValue(projectPayload.title),
                iconURLString: normalizedValue(projectPayload.iconURL),
                projectURLString: projectURL(slug: projectPayload.slug, projectId: projectPayload.id),
                authors: authors
            )
            
            metadataByHash[sha1] = MetadataCacheEntry(metadata: metadata, createdAt: Date())
            return metadata
        } catch {
            return nil
        }
    }
}

private extension FTBModpackVersionModMetadataService {
    func fetchVersionPayload(hash: String) async throws -> ModrinthVersionFilePayload {
        let encodedHash = hash.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? hash
        let urlString = "https://api.modrinth.com/v2/version_file/\(encodedHash)?algorithm=sha1"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        return try await request(url: url)
    }
    
    func fetchProjectPayload(projectId: String) async throws -> ModrinthProjectPayload {
        if let cached = projectById[projectId], Date().timeIntervalSince(cached.createdAt) < cacheTTL {
            return cached.payload
        }
        
        let encodedProjectId = projectId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? projectId
        let urlString = "https://api.modrinth.com/v2/project/\(encodedProjectId)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let payload: ModrinthProjectPayload = try await request(url: url)
        projectById[projectId] = ProjectCacheEntry(payload: payload, createdAt: Date())
        return payload
    }
    
    func fetchAuthors(projectId: String, fallbackAuthorId: String?) async throws -> [FTBModpackAuthor] {
        if let cached = authorsByProjectId[projectId], Date().timeIntervalSince(cached.createdAt) < cacheTTL {
            return cached.authors
        }
        
        let encodedProjectId = projectId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? projectId
        let urlString = "https://api.modrinth.com/v2/project/\(encodedProjectId)/members"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let members: [ModrinthProjectMemberPayload] = try await request(url: url)
        
        let authorsFromMembers = members
            .sorted {
                ($0.ordering ?? Int.max) < ($1.ordering ?? Int.max)
            }
            .compactMap { member -> FTBModpackAuthor? in
                let username = normalizedValue(member.user.username)
                guard let username else {
                    return nil
                }
                
                return FTBModpackAuthor(
                    id: member.user.id ?? username,
                    name: username,
                    profileURLString: userURL(username)
                )
            }
        
        if authorsFromMembers.isEmpty == false {
            let deduplicated = deduplicatedAuthors(authorsFromMembers)
            authorsByProjectId[projectId] = AuthorCacheEntry(authors: deduplicated, createdAt: Date())
            return deduplicated
        }
        
        guard let fallbackAuthorId = normalizedValue(fallbackAuthorId) else {
            authorsByProjectId[projectId] = AuthorCacheEntry(authors: [], createdAt: Date())
            return []
        }
        
        if let cachedUsername = usernameById[fallbackAuthorId] {
            let fallbackAuthor = FTBModpackAuthor(
                id: fallbackAuthorId,
                name: cachedUsername,
                profileURLString: userURL(cachedUsername)
            )
            authorsByProjectId[projectId] = AuthorCacheEntry(authors: [fallbackAuthor], createdAt: Date())
            return [fallbackAuthor]
        }
        
        let encodedAuthorId = fallbackAuthorId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fallbackAuthorId
        let fallbackURLString = "https://api.modrinth.com/v2/user/\(encodedAuthorId)"
        
        guard let fallbackURL = URL(string: fallbackURLString) else {
            throw URLError(.badURL)
        }
        
        let fallbackUser: ModrinthUserPayload = try await request(url: fallbackURL)
        guard let username = normalizedValue(fallbackUser.username) else {
            authorsByProjectId[projectId] = AuthorCacheEntry(authors: [], createdAt: Date())
            return []
        }
        
        usernameById[fallbackAuthorId] = username
        let fallbackAuthor = FTBModpackAuthor(
            id: fallbackAuthorId,
            name: username,
            profileURLString: userURL(username)
        )
        authorsByProjectId[projectId] = AuthorCacheEntry(authors: [fallbackAuthor], createdAt: Date())
        return [fallbackAuthor]
    }
    
    func request<Response: Decodable>(url: URL) async throws -> Response {
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bisquit-Host", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(Response.self, from: data)
    }
    
    func normalizedHash(_ value: String?) -> String? {
        guard let value = normalizedValue(value) else {
            return nil
        }
        
        return value.lowercased()
    }
    
    func normalizedValue(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    func projectURL(slug: String?, projectId: String?) -> String? {
        if let slug = normalizedValue(slug),
           let encoded = slug.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            return "https://modrinth.com/mod/\(encoded)"
        }
        
        if let projectId = normalizedValue(projectId),
           let encoded = projectId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            return "https://modrinth.com/mod/\(encoded)"
        }
        
        return nil
    }
    
    func userURL(_ username: String?) -> String? {
        guard let username = normalizedValue(username),
              let encoded = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        return "https://modrinth.com/user/\(encoded)"
    }
    
    func deduplicatedAuthors(_ authors: [FTBModpackAuthor]) -> [FTBModpackAuthor] {
        var seen = Set<String>()
        var output: [FTBModpackAuthor] = []
        
        for author in authors {
            let key = author.name.lowercased()
            guard seen.insert(key).inserted else {
                continue
            }
            
            output.append(author)
        }
        
        return output
    }
}

nonisolated private struct ModrinthVersionFilePayload: Decodable {
    let projectId: String?
    let authorId: String?
    
    private enum CodingKeys: String, CodingKey {
        case projectId = "project_id"
        case authorId = "author_id"
    }
}

nonisolated private struct ModrinthProjectPayload: Decodable {
    let id: String?
    let title: String?
    let slug: String?
    let iconURL: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, title, slug
        case iconURL = "icon_url"
    }
}

nonisolated private struct ModrinthProjectMemberPayload: Decodable {
    let ordering: Int?
    let user: ModrinthProjectMemberUserPayload
}

nonisolated private struct ModrinthProjectMemberUserPayload: Decodable {
    let id: String?
    let username: String?
}

nonisolated private struct ModrinthUserPayload: Decodable {
    let username: String?
}
