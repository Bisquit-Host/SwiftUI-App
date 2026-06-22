import Calagopus

@Observable
final class AllocationVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var allocations: [CalagopusServerAllocation] = []
    
    func fetchAllocations() async {
        do {
            allocations = try await CalagopusNet.client().allocations(server: id).data
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func setDefault(_ allocationId: String) async {
        do {
            try await CalagopusNet.client().updateAllocation(server: id, allocation: allocationId, isPrimary: true)
            await fetchAllocations()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func unassignAllocation(_ allocationId: String) async {
        do {
            try await CalagopusNet.client().deleteAllocation(server: id, allocation: allocationId)
            await fetchAllocations()
        } catch {
            SystemAlert.error(error)
        }
    }
}
