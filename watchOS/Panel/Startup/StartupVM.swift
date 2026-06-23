import Calagopus

@Observable
final class StartupVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var startupCommand = ""
    private(set) var startupVariables: [CalagopusServerVariable] = []
    
    func fetchStartupVariables() async {
        do {
            async let variables = CalagopusNet.client().startupVariables(server: id)
            async let serverDetails = CalagopusNet.client().server(id: id)
            
            let (startupVariables, details) = try await (variables, serverDetails)
            
            self.startupVariables = startupVariables
            startupCommand = details.startup
        } catch {
            SystemAlert.error(error)
        }
    }
}
