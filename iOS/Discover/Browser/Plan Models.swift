struct MinecraftPlan: Identifiable, Decodable {
    let id, ram, disk, mysql: Int
    let name, location, displayname, cpu_model, cpu: String
    let price_rub, price_eur, price_usd: Double
}

struct VdsPlan: Identifiable, Decodable {
    let id, disk, network, ram, cpu: Int
    let name, displayname: String
    let priceRub, priceEur, priceUsd: Double
}

struct WebPlan: Identifiable, Decodable {
    let id, disk, mysql, sites: Int
    let name, displayname: String
    let priceRub, priceEur, priceUsd: Double
}

struct BotPlan: Identifiable, Decodable {
    let id, disk, mysql: Int
    let name, displayname, ram, cpu: String
    let priceRub, priceEur, priceUsd: Double
}
