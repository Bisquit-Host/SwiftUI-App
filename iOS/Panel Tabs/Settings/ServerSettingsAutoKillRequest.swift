struct ServerSettingsAutoKillRequest: Encodable {
    let enabled: Bool
    let seconds: Int64?
}
