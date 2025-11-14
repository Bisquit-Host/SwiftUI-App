import PteroNet

@Observable
final class AllocationVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var allocations: [AllocationAttributes] = []
    private(set) var categories: [AllocationCategory] = []
    
    func fetchAllocations() async {
        do {
            allocations = try await allocationListAPI(id)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func setDefault(_ allocId: Int) async {
        do {
            _ = try await allocationSetPrimaryAPI(id, allocationId: allocId)
            await fetchAllocations()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func unassignAllocation(_ allocId: Int) async {
        do {
            try await allocationDeleteAPI(id, allocationId: allocId)
            await fetchAllocations()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchCategories() async {
        do {
            categories = try await allocationCategoriesAPI(id)
            print("✅ Fetched \(categories.count) categories")
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func assignAllocation(
        _ category: Int,
        onSuccess: @escaping () -> Void = {}
    ) async {
        do {
            _ = try await allocationCreateAPI(id, category: category, printResponse: true)
            await fetchAllocations()
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func updateNotes(_ allocId: Int, notes: String) async {
        do {
            _ = try await allocationNoteAPI(id, allocationId: allocId, notes: notes)
            await fetchAllocations()
        } catch {
            SystemAlert.error(error)
        }
    }
}
