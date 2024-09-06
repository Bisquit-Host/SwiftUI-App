import PteroNet

struct Asset: Codable {
    let id: String
    let name: String
}

struct AssetDetails: Codable {
    let state: String
    var test: ResourceUsageAttributes? = nil
}
