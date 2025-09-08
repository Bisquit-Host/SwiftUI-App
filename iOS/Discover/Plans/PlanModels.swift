struct PlanResponse: Decodable {
    let result: PlanList
}

struct PlanList: Decodable {
    let packages: [UniversalPlan]
}

//"id":1,
//"name":"BW-Morning",
//"price":[
//    {
//        "price":59,
//        "currency":"rub",
//    },
//    {
//        "price":0.99,
//        "currency":"eur",
//    }
//],
//"site":5,
//"databases":1,
//"disk":2048,
//"diskType":"SSD",
//"whmcsLink":"/store/web/bw-morning",
//"enabled":true,

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
}

struct PlanPrice: Decodable {
    let price: Double
    let currency: String
}

struct PlanLocation: Decodable {
    let id: Int
    let name: String
    let flagUrl: String
    let remarks: [String]
    let enabled: Bool
}
