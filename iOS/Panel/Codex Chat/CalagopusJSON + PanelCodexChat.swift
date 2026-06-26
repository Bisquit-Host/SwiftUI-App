import Calagopus

extension CalagopusJSON {
    var objectValue: [String: CalagopusJSON]? {
        if case .object(let value) = self {
            return value
        }
        
        return nil
    }
    
    var arrayValue: [CalagopusJSON]? {
        if case .array(let value) = self {
            return value
        }
        
        return nil
    }
    
    var stringValue: String? {
        if case .string(let value) = self {
            return value
        }
        
        return nil
    }
    
    var boolValue: Bool? {
        if case .bool(let value) = self {
            return value
        }
        
        return nil
    }
    
    var intValue: Int? {
        switch self {
        case .number(let value): Int(value)
        case .string(let value): Int(value)
        default: nil
        }
    }
}
