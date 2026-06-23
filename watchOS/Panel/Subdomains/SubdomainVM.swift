import SwiftUI
import Calagopus

@Observable
final class SubdomainVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private var subdomainResponse: CalagopusSubdomainsOverview?
    
    var limit: Int {
        subdomainResponse?.limit ?? 0
    }
    
    var subdomains: [CalagopusSubdomainRecord] {
        subdomainResponse?.subdomains ?? []
    }
    
    func fetchSubdomains() async {
        do {
            let response = try await CalagopusNet.client().subdomainsOverview(server: id)
            subdomainResponse = response
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func syncSubdomain(_ subdomainId: String) async {
        guard
            let subdomain = subdomains.first(where: { $0.id == subdomainId }),
            let allocationUuid = subdomain.allocation?.uuid
        else {
            return
        }
        
        do {
            try await CalagopusNet.client().syncSubdomain(server: id, subdomain: subdomain.uuid, allocation: allocationUuid)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteSubdomain(_ subdomainId: String) async {
        guard let subdomain = subdomains.first(where: { $0.id == subdomainId }) else {
            return
        }
        
        do {
            try await CalagopusNet.client().deleteSubdomain(server: id, subdomain: subdomain.uuid)
            await fetchSubdomains()
        } catch {
            SystemAlert.error(error)
        }
    }
}
