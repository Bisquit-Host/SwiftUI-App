import Calagopus

struct AgentQuestion: Hashable {
    let question: String
    let header: String
    let options: [AgentQuestionOption]
    let multiSelect: Bool
    
    init?(_ json: CalagopusJSON) {
        guard
            let object = json.objectValue,
            let question = object["question"]?.stringValue
        else {
            return nil
        }
        
        self.question = question
        header = object["header"]?.stringValue ?? ""
        options = object["options"]?.arrayValue?.compactMap(AgentQuestionOption.init) ?? []
        multiSelect = object["multiSelect"]?.boolValue ?? false
    }
}
