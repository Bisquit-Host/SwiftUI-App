import CloudKit

struct MinecraftPlan: Identifiable, Decodable {
    let id, ram, disk, mysql: Int
    let name, location, displayname, cpu_model, cpu: String
    let price_rub, price_eur, price_usd: Double
}

struct Plan: Identifiable, Decodable {
    let id, disk: Int
    let name, displayName: String
    let priceRub, priceEur, priceUsd: Double
    let ram, cpu: Double?
    let location, cpuModel: String?
    let mysql, network, sites: Int?
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
