import PteroNet

enum Route: Hashable, Codable {
    case server(ServerAttributes),
         tab(Tabs)
}
