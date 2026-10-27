import Foundation

@Observable
final class VDSChangePasswordVM {
    var password = ""
    var isPasswordVisible = false

    var isValid: Bool {
        let count = password.trimmingCharacters(in: .whitespacesAndNewlines).count
        return (8...32).contains(count)
    }

    func generatePassword() {
        // Matches billing's useString.randomString(24)
        let characters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        var generator = SystemRandomNumberGenerator()

        password = String((0..<24).map { _ in
            characters[Int.random(in: characters.indices, using: &generator)]
        })
    }
}
