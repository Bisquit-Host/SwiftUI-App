import Foundation

enum BillingAppAccountToken {
    static func token(for userID: Int) -> UUID? {
        guard userID > 0 else { return nil }

        let userIDString = String(userID)
        let compactToken = String(repeating: "0", count: 32 - userIDString.count) + userIDString
        let firstSegment = compactToken.prefix(8)
        let secondSegment = compactToken.dropFirst(8).prefix(4)
        let thirdSegment = compactToken.dropFirst(12).prefix(4)
        let fourthSegment = compactToken.dropFirst(16).prefix(4)
        let fifthSegment = compactToken.dropFirst(20).prefix(12)
        let tokenString = "\(firstSegment)-\(secondSegment)-\(thirdSegment)-\(fourthSegment)-\(fifthSegment)"

        return UUID(uuidString: tokenString)
    }
}
