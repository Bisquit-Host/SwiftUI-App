import Foundation

public struct User: Decodable {
    public let id: Int
    public let login: String
    public let email: String
    public let emailVerified: Bool
    public let name: String
    public let avatar: String
    public let currency: String
    public let balance: Int
    public let bonusBalance: Int
    public let totalBalance: Int
    public let lang: String
    public let twoFa: Bool
    public let githubId: String
    public let isBanned: Bool
    public let hasPassword: Bool
    public let isSupportAgent: Bool
    public let isSupport: Bool
    public let isAdmin: Bool
    public let isGod: Bool
    public let createdAt: String
    public let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, login, email, emailVerified, name, avatar, currency, balance, bonusBalance, totalBalance, lang, twoFa, githubId, isBanned, hasPassword, isSupportAgent, isSupport = "rawIsSupport", isAdmin = "rawIsAdmin", isGod = "rawIsGod", createdAt, updatedAt
    }
}

//{
//    "id": 3,
//    "login": "gh-ezh9H8yM",
//    "email": "sergei_saliukov@icloud.com",
//    "emailVerified": true,
//    "name": "Sergei Saliukov",
//    "avatar": "https://avatars.githubusercontent.com/u/89252798?v=4",
//    "currency": "RUB",
//    "balance": 0,
//    "bonusBalance": 0,
//    "totalBalance": 0,
//    "lang": "RU",
//    "twoFa": false,
//    "githubId": "89252798",
//    "isBanned": false,
//    "hasPassword": true,
//    "isSupportAgent": true,
//    "isAdmin": true,
//    "isGod": true,
//    "rawIsSupport": false,
//    "rawIsAdmin": false,
//    "rawIsGod": true,
//    "createdAt": "2025-10-07T01:18:16.169036Z",
//    "updatedAt": "2025-11-23T21:49:26.043350Z"
//}
