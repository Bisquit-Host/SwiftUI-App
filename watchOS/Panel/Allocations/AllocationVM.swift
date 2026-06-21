import Calagopus

@Observable
final class AllocationVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var allocations: [AllocationAttributes] = []
    
    func fetchAllocations() async {
        do {
            allocations = try await allocationListAPI(id)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func setDefault(_ allocationId: Int) async {
        do {
            _ = try await allocationSetPrimaryAPI(id, allocationId: allocationId)
            await fetchAllocations()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func unassignAllocation(_ allocationId: Int) async {
        do {
            try await allocationDeleteAPI(id, allocationId: allocationId)
            await fetchAllocations()
        } catch {
            SystemAlert.error(error)
        }
    }
}
