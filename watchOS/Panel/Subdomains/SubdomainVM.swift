import SwiftUI
import PteroNet

@Observable
final class SubdomainVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private var subdomainResponse: SubdomainResponse?
    
    var limit: Int {
        subdomainResponse?.limit ?? 0
    }
    
    var subdomains: [SubdomainAttributes] {
        subdomainResponse?.subdomains.map(\.attributes) ?? []
    }
    
    func fetchSubdomains() async {
        do {
            let response = try await fetchSubdomainsAPI(id)
            subdomainResponse = response
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func syncSubdomain(_ subdomainId: Int) async {
        do {
            let _ = try await syncSubdomainAPI(id, subdomainId: subdomainId)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteSubdomain(_ subdomainId: Int) async {
        do {
            let _ = try await deleteSubdomainAPI(id, subdomainId: subdomainId)
            await fetchSubdomains()
        } catch {
            SystemAlert.error(error)
        }
    }
}
