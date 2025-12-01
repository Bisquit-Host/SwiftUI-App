import AuthenticationServices
import Foundation

@Observable
final class BillingPasskeysVM {
    var passkeys: [PasskeyListItem] = []
    var isLoading = false
    var isRegistering = false
    var error: String?
    var label: String = ""

    private let baseURL = URL(string: "https://test-api.bisquit.host")!
    private let authController = PasskeyAuthorizationController()

    func fetchPasskeys() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }

        defer {
            Task { @MainActor in
                isLoading = false
            }
        }

        guard let token = ValueStore().testAccessToken.nonEmpty else {
            await MainActor.run {
                error = "Missing access token"
            }
            return
        }

        let url = baseURL.appendingPathComponent("user/passkeys")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let status = (response as? HTTPURLResponse)?.statusCode, status == 200 else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let items = try decoder.decode([PasskeyListItem].self, from: data)

            await MainActor.run {
                passkeys = items
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }

    func deletePasskey(_ passkey: PasskeyListItem) async {
        guard let token = ValueStore().testAccessToken.nonEmpty else {
            await MainActor.run {
                error = "Missing access token"
            }
            return
        }

        let url = baseURL.appendingPathComponent("user/passkeys/\(passkey.id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let status = (response as? HTTPURLResponse)?.statusCode, status == 204 else {
                throw URLError(.cannotRemoveFile)
            }

            await MainActor.run {
                passkeys.removeAll { $0.id == passkey.id }
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }

    func registerPasskey() async {
        guard let token = ValueStore().testAccessToken.nonEmpty else {
            await MainActor.run {
                error = "Missing access token"
            }
            return
        }

        await MainActor.run {
            isRegistering = true
            error = nil
        }

        defer {
            Task { @MainActor in
                isRegistering = false
            }
        }

        do {
            let session = try await startRegistration(token: token)
            let request = try PasskeyRequestFactory.registrationRequest(from: session.options)
            let credential = try await authController.perform(request)

            guard let registration = credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration else {
                throw PasskeyError.invalidCredential
            }

            let payload = try PasskeyCredentialFormatter.attestationPayload(registration)

            try await verifyRegistration(sessionId: session.sessionId, credential: payload, token: token)

            await MainActor.run {
                label = ""
            }

            await fetchPasskeys()
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
            print("Passkey registration failed:", error.localizedDescription)
        }
    }

    private func startRegistration(token: String) async throws -> PasskeyOptionsResponse<PasskeyRegistrationOptions> {
        let url = baseURL.appendingPathComponent("user/passkeys/register/options")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let label = label.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["label": label])
        } else {
            request.httpBody = "{}".data(using: .utf8)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let status = (response as? HTTPURLResponse)?.statusCode, status == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(PasskeyOptionsResponse<PasskeyRegistrationOptions>.self, from: data)
    }

    private func verifyRegistration(sessionId: String, credential: [String: Any], token: String) async throws {
        let url = baseURL.appendingPathComponent("user/passkeys/register/verify")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "sessionId": sessionId,
            "credential": credential
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let status = (response as? HTTPURLResponse)?.statusCode, status == 201 else {
            throw URLError(.badServerResponse)
        }
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
