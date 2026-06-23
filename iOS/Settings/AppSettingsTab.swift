enum AppSettingsTab: String {
#if os(visionOS)
    case account, app
#else
    case account, app, pterodactyl
#endif
}
