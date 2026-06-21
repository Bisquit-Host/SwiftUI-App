import Calagopus

@Observable
final class StartupVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var startupCommand = ""
    private(set) var startupVariables: [StartupVariable] = []
    
    func fetchStartupVariables() async {
        do {
            let model = try await startupListAPI(id)
            
            startupVariables = model.data.map(\.attributes)
            startupCommand = model.meta.startupCommand
        } catch {
            SystemAlert.error(error)
        }
    }
}
