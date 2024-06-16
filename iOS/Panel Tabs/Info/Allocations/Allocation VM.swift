import PteroNet

@Observable
final class AllocationVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var allocations: [AllocationAttributes] = []
    
    func fetchAllocations() {
        allocationListAPI(id) { result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    self.allocations = model.map(\.attributes)
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func setDefault(_ allocationId: Int) {
        allocationSetPrimaryAPI(id, allocationId: allocationId) { result in
            switch result {
            case .success/*(let model)*/:
                self.fetchAllocations()
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func unassignAllocation(_ allocationId: Int) {
        allocationDeleteAPI(id, allocationId: allocationId) { result in
            switch result {
            case .success:
                self.fetchAllocations()
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func assignAllocation() {
        allocationCreateAPI(id, printResponse: true) { result in
            switch result {
            case .success/*(let model)*/:
                self.fetchAllocations()
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func updateNotes(_ allocationId: Int, notes: String) {
        allocationNoteAPI(id, allocationId: allocationId, notes: notes) { result in
            switch result {
            case .success/*(let model)*/:
                self.fetchAllocations()
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
