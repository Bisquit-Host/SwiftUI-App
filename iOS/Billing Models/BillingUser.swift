import Foundation
import BisquitoNet

public struct BillingUser: Decodable, Equatable {
    public let id: Int
    
    /// 2-100 symbols
    public let login: String
    
    /// 2-100 symbols
    public let email: String
    
    public let emailVerified: Bool
    
    /// 2-100 symbols
    public let name: String
    
    public let avatar: String?
    public let currency: BillingCurrency
    public let balance: Double
    public let bonusBalance: Double
    public let totalBalance: Double
    public let lang: String
    public let twoFa: Bool
    public let githubId: String?
    public let googleId: String?
    public let yandexId: String?
    public let isBanned: Bool
    public let hasPassword: Bool
    public let isSupportAgent: Bool
    public let isSupport: Bool
    public let isAdmin: Bool
    public let isGod: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, login, email, emailVerified, name, avatar, currency, balance, bonusBalance, totalBalance, lang, twoFa, githubId, googleId, yandexId, isBanned, hasPassword, isSupportAgent, isSupport = "rawIsSupport", isAdmin = "rawIsAdmin", isGod = "rawIsGod", createdAt, updatedAt
    }
    
    public static let preview = BillingUser(
        id: 1,
        login: "test",
        email: "test@example.com",
        emailVerified: true,
        name: "Test User",
        avatar: "https://example.com/avatar.png",
        currency: .EUR,
        balance: 1000,
        bonusBalance: 200,
        totalBalance: 1200,
        lang: "en",
        twoFa: true,
        githubId: "123456",
        googleId: "google-abc",
        yandexId: "yandex-xyz",
        isBanned: false,
        hasPassword: true,
        isSupportAgent: false,
        isSupport: false,
        isAdmin: false,
        isGod: false,
        createdAt: Date(),
        updatedAt: Date()
    )
}
