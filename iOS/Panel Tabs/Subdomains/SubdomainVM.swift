import PteroNet

@Observable
final class SubdomainVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var subdomain = ""
    var selectedDomain = 1
    var selectedAllocation: Int?
    
    private var subdomainResponse: SubdomainResponse?
    
    var disabled: Bool {
        subdomains.count >= limit
    }
    
    var limit: Int {
        subdomainResponse?.limit ?? 0
    }
    
    var domains: [Domain]? {
        subdomainResponse?.domains
    }
    
    var subdomains: [SubdomainAttributes] {
        subdomainResponse?.subdomains.map(\.attributes) ?? []
    }
    
    func deleteSubdomain(_ subdomainId: Int) async {
        do {
            let _ = try await deleteSubdomainAPI(id, subdomainId: subdomainId)
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
    
    func createSubdomain(onSuccess: @escaping () -> Void) async {
        guard
            limit > subdomains.count,
            let selectedAllocation
        else {
            return
        }
        
        print("Creating subdomain", subdomain, "on domain", selectedDomain, "for server", id)
        
        do {
            let _ = try await createSubdomainAPI(
                id,
                subdomain: subdomain,
                selectedDomain: selectedDomain,
                selectedAllocation: selectedAllocation
            )
            
            await fetchSubdomains()
            
            self.selectedAllocation = nil
            subdomain = ""
            
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchSubdomains() async {
        do {
            let response = try await fetchSubdomainsAPI(id)
            self.subdomainResponse = response
        } catch {
            SystemAlert.error(error)
        }
    }
}
