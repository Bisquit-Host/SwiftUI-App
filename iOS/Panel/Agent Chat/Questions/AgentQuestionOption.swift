import Calagopus

struct AgentQuestionOption: Hashable {
    let label: String
    let description: String
    
    init?(_ json: CalagopusJSON) {
        guard
            let object = json.objectValue,
            let label = object["label"]?.stringValue
        else {
            return nil
        }
        
        self.label = label
        description = object["description"]?.stringValue ?? ""
    }
}
