extension CacheLimit {
    enum CacheLimit: String {
        case MB50 = "50 MB"
        case MB250 = "250 MB"
        case GB1 = "1 GB"
    }
}

extension CacheExpiration {
    enum CacheExpiration: String {
        case day, week, month, year, never
    }
}
