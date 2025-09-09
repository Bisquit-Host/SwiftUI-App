struct UniversalPlan: Identifiable, Decodable {
    let id: Int
    let name: String
    let locationId: Int?
    let price: [PlanPrice]
    let cpu: Double?
    let cpuName: String?
    let memory: Int?
    let memoryType: String?
    let disk: Int
    let backups: Int?
    let databases: Int?
    let allocations: Int?
    let diskType: String
    let network: Int?
    let networkType: String?
    let nests: [String]?
    let bonusBalanceAllowed: Bool?
    let windowsAllowed: Bool?
    let antiSpoofing: Bool?
    let whmcsLink: String
    let enabled: Bool
    let site: Int?
    
    var memoryGB: Double? {
        if let memory {
            Double(memory) / 1024
        } else {
            nil
        }
    }
    
    var diskGB: Int {
        disk / 1024
    }
}
