import ScrechKit
import PteroNet

@Observable
final class DatabaseVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var databases: [DatabaseAttributes] = []
    var newDatabaseName = ""
    
    func fetchDatabases() {
        dataListAPI(id, endpoint: .databases) { (result: Result<DatabaseListResponse?, Error>) in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    withAnimation {
                        self.databases = model.map {
                            $0.attributes
                        }
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func rotateDatabasePassword(_ dbId: String) {
        databaseRotatePasswordAPI(id, dbId: dbId) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    if let index = self.databases.firstIndex(where: { $0.id == model.id }) {
                        self.databases[index] = model
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func createDatabase() {
        databaseCreateAPI(id, name: newDatabaseName) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    withAnimation {
                        self.databases.append(model)
                    }
                    
                    self.newDatabaseName = ""
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func deleteDatabases(_ offsets: IndexSet) {
        for index in offsets {
            let id = databases[index].id
            deleteDatabase(id)
        }
    }
    
    func deleteDatabase(_ uuid: String) {
        dataDeleteAPI(id, itemId: uuid, endpoint: .databases) { result in
            switch result {
            case .success:
                self.fetchDatabases()
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
