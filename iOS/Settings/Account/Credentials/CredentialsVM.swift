import PteroNet

@Observable
final class CredentialsVM {
    func updateCredentials(type: UpdateType) async {
        do {
            try await credentialsUpdateAPI(type: type)
        } catch {
            SystemAlert.error(error)
        }
    }
}
