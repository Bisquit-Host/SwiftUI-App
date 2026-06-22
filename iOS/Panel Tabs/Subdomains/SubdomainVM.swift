import Calagopus

@Observable
final class SubdomainVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var subdomain = ""
    var selectedDomain: String?
    var selectedAllocation: String?
    var limit: Int?
    
    private var subdomainResponse: SubdomainResponse?
    
    var disabled: Bool {
        limit == 0 || limit.map { subdomains.count >= $0 } == true
    }
    
    var domains: [Domain]? {
        subdomainResponse?.domains
    }
    
    var subdomains: [SubdomainAttributes] {
        subdomainResponse?.subdomains.map(\.attributes) ?? []
    }
    
    var canCreateSubdomain: Bool {
        selectedDomain != nil
        && selectedAllocation != nil
        && !subdomain.isEmpty
        && !disabled
    }
    
    func updateLimit(_ limit: Int?) {
        self.limit = limit
    }
    
    func deleteSubdomain(_ subdomain: SubdomainAttributes) async {
        do {
            let _ = try await deleteSubdomainAPI(id, subdomainId: subdomain.uuid)
            await fetchSubdomains()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteSubdomain(_ subdomainId: Int) async {
        guard let subdomain = subdomains.first(where: { $0.id == subdomainId }) else {
            return
        }
        
        await deleteSubdomain(subdomain)
    }
    
    func syncSubdomain(_ subdomain: SubdomainAttributes) async {
        guard let allocationUuid = subdomain.allocationUuid else {
            return
        }
        
        do {
            let _ = try await syncSubdomainAPI(id, subdomainId: subdomain.uuid, allocationId: allocationUuid)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func syncSubdomain(_ subdomainId: Int) async {
        guard let subdomain = subdomains.first(where: { $0.id == subdomainId }) else {
            return
        }
        
        await syncSubdomain(subdomain)
    }
    
    func createSubdomain(onSuccess: @escaping () -> Void) async {
        guard canCreateSubdomain, let selectedDomain, let selectedAllocation else {
            return
        }
        
        Logger().info("Creating subdomain \(self.subdomain) on domain \(selectedDomain) for server \(self.id)")
        
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
            limit = limit ?? response.limit
            selectedDomain = selectedDomain ?? response.domains.first?.id
        } catch {
            SystemAlert.error(error)
        }
    }
}
