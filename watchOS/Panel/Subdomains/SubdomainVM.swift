import SwiftUI
import Calagopus

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
        guard
            let subdomain = subdomains.first(where: { $0.id == subdomainId }),
            let allocationUuid = subdomain.allocationUuid
        else {
            return
        }
        
        do {
            let _ = try await syncSubdomainAPI(id, subdomainId: subdomain.uuid, allocationId: allocationUuid)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteSubdomain(_ subdomainId: Int) async {
        guard let subdomain = subdomains.first(where: { $0.id == subdomainId }) else {
            return
        }
        
        do {
            let _ = try await deleteSubdomainAPI(id, subdomainId: subdomain.uuid)
            await fetchSubdomains()
        } catch {
            SystemAlert.error(error)
        }
    }
}
