import SwiftUI
import Calagopus

@Observable
final class LogMetaListVM {
    private(set) var simpleProperties: [(key: String, value: String)] = []
    private(set) var arrayProperties: [(key: String, value: [String])] = []
    
    func prepareProperties(_ properties: [String: CalagopusLogValue]) {
        var simpleProperties: [String: String] = [:]
        var arrayProperties: [String: [String]] = [:]
        
        properties.forEach { key, value in
            switch value {
            case .int(let x):
                simpleProperties[key] = String(x)
                
            case .string(let x):
                simpleProperties[key] = x
                
            case .bool(let x):
                simpleProperties[key] = String(x)
                
            case .array(let x):
                arrayProperties[key] = x
                
            case .none:
                simpleProperties[key] = "None"
            }
        }
        
        self.simpleProperties = simpleProperties.sorted { $0.key < $1.key }
        self.arrayProperties = arrayProperties.sorted { $0.key < $1.key }
    }
}
