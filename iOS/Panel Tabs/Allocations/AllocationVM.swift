import Calagopus

@Observable
final class AllocationVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var allocations: [CalagopusServerAllocation] = []
    private(set) var categories: [CalagopusAllocationCategory] = []
    
    func fetchAllocations() async {
        do {
            allocations = try await CalagopusNet.client().allocations(server: id).data
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func setDefault(_ allocId: String) async {
        do {
            try await CalagopusNet.client().updateAllocation(server: id, allocation: allocId, isPrimary: true)
            await fetchAllocations()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func unassignAllocation(_ allocId: String) async {
        do {
            try await CalagopusNet.client().deleteAllocation(server: id, allocation: allocId)
            await fetchAllocations()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchCategories() async {
        do {
            categories = try await CalagopusNet.client().allocationCategories(server: id)
            Logger().info("Fetched \(self.categories.count) categories")
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func assignAllocation(_ category: Int, onSuccess: @escaping () -> Void = {}) async {
        do {
            _ = try await CalagopusNet.client().createAllocation(server: id, categoryID: category)
            await fetchAllocations()
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func updateNotes(_ allocId: String, notes: String) async {
        do {
            try await CalagopusNet.client().updateAllocation(server: id, allocation: allocId, notes: notes)
            await fetchAllocations()
        } catch {
            SystemAlert.error(error)
        }
    }
}
