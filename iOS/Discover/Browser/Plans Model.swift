import CloudKit

struct MinecraftPlan: Identifiable, Decodable {
    let id, ram, disk, mysql: Int
    let name, location, displayname, cpu_model, cpu: String
    let price_rub, price_eur, price_usd: Double
}
