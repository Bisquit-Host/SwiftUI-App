struct PlanResponse: Decodable {
    let result: PlanList
}

struct PlanList: Decodable {
    let packages: [UniversalPlan]
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
