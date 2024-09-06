struct WidgetServerListResponse: Decodable {
    let data: [WidgetServer]
}

struct WidgetServer: Decodable {
    let attributes: WidgetServerAttributes
}

struct WidgetServerAttributes: Decodable {
    let identifier: String
    let name: String
}
