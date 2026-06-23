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
    
    private var subdomainResponse: CalagopusSubdomainsOverview?
    
    var disabled: Bool {
        limit == 0 || limit.map { subdomains.count >= $0 } == true
    }
    
    var domains: [CalagopusSubdomainDomain]? {
        subdomainResponse?.domains
    }
    
    var subdomains: [CalagopusSubdomainRecord] {
        subdomainResponse?.subdomains ?? []
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
    
    func deleteSubdomain(_ subdomain: CalagopusSubdomainRecord) async {
        do {
            try await CalagopusNet.client().deleteSubdomain(server: id, subdomain: subdomain.uuid)
            await fetchSubdomains()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteSubdomain(_ subdomainId: Int) async {
        guard let subdomain = subdomains.first(where: { $0.id == subdomainId.description }) else {
            return
        }
        
        await deleteSubdomain(subdomain)
    }
    
    func syncSubdomain(_ subdomain: CalagopusSubdomainRecord) async {
        guard let allocationUuid = subdomain.allocation?.uuid else {
            return
        }
        
        do {
            try await CalagopusNet.client().syncSubdomain(server: id, subdomain: subdomain.uuid, allocation: allocationUuid)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func syncSubdomain(_ subdomainId: Int) async {
        guard let subdomain = subdomains.first(where: { $0.id == subdomainId.description }) else {
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
            try await CalagopusNet.client().createSubdomain(
                server: id,
                subdomain: subdomain,
                domain: selectedDomain,
                allocation: selectedAllocation
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
            let response = try await CalagopusNet.client().subdomainsOverview(server: id)
            self.subdomainResponse = response
            limit = limit ?? response.limit
            selectedDomain = selectedDomain ?? response.domains.first?.id
        } catch {
            SystemAlert.error(error)
        }
    }
}
