struct PlanResponse: Decodable {
    let result: PlanList
}

struct PlanList: Decodable {
    let packages: [UniversalPlan]
    let locations: [PlanLocation]?
}

struct PlanLocation: Identifiable, Decodable {
    let id: Int
    let name: String
    let flagUrl: String
    let remarks: [String]
    let enabled: Bool
}

struct PlanPrice: Decodable {
    let price: Double
    let currency: String
}
