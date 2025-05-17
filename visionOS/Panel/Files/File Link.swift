struct FileLink: Codable, Hashable {
    let id: String
    let name: String
    let root: String
    
    init(_ id: String, name: String, at root: String) {
        self.id = id
        self.name = name
        self.root = root
    }
}
