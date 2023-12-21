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
                    self.allocations = model.map {
                        $0.attributes
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
