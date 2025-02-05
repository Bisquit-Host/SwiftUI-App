import CloudKit

struct MinecraftPlan: Identifiable, Decodable {
    let id, ram, disk, mysql: Int
    let name, location, displayname, cpu_model, cpu: String
    let price_rub, price_eur, price_usd: Double
}

struct Plan: Identifiable, Decodable {
    let id: Int
    let name: String
    let displayName: String
    let priceRub: Double
    let priceEur: Double
    let priceUsd: Double
    let disk: Int
    
    let ram: Double?
    let cpu: Double?
    let mysql: Int?
    let location: String?
    let cpuModel: String?
    let network: Int?
    let sites: Int?
}

/// MC
//{
//    "ram": 2,
//    "cpu": "1",
//}

/// Bots
//{
//    "ram": "0.5",
//    "cpu": "0.5",
//}

/// VDS
//{
//    "ram": 4,
//    "cpu": 2,
//}
