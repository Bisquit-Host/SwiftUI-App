import PteroNet

@Observable
final class AllocationVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var allocations: [AllocationAttributes] = []
    private(set) var categories: [AllocationCategory] = []
    
    func fetchAllocations() {
        allocationListAPI(id) { result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    self.allocations = model.map(\.attributes)
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func setDefault(_ allocId: Int) {
        allocationSetPrimaryAPI(id, allocationId: allocId) { result in
            switch result {
            case .success/*(let model)*/:
                self.fetchAllocations()
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func unassignAllocation(_ alloсId: Int) {
        allocationDeleteAPI(id, allocationId: alloсId) { result in
            switch result {
            case .success:
                self.fetchAllocations()
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func fetchCategories() {
        allocationCategoriesAPI(id) { result in
            switch result {
            case .success(let model):
                if let model {
                    self.categories = model
                    print("✅ Fethced \(model.count) categories")
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func assignAllocation(_ category: Int, onSuccess: @escaping () -> Void = {}) {
        allocationCreateAPI(id, category: category, printResponse: true) { result in
            switch result {
            case .success/*(let model)*/:
                self.fetchAllocations()
                onSuccess()
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func updateNotes(_ allocId: Int, notes: String) {
        allocationNoteAPI(id, allocationId: allocId, notes: notes) { result in
            switch result {
            case .success/*(let model)*/:
                self.fetchAllocations()
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
}
