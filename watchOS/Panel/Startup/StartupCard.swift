import ScrechKit
import Calagopus

struct StartupCard: View {
    private let variable: StartupVariable
    
    init(_ variable: StartupVariable) {
        self.variable = variable
    }
    
    private var currentValue: String {
        variable.serverValue ?? variable.defaultValue
    }
    
    var body: some View {
        Section(variable.name) {
            Text(variable.description)
                .caption()
                .secondary()
            
            LabeledContent("Value") {
                Text(currentValue)
                    .caption(design: .monospaced)
                    .multilineTextAlignment(.trailing)
            }
            
            LabeledContent("Variable") {
                Text(variable.envVariable)
                    .caption2(design: .monospaced)
                    .secondary()
            }
        }
    }
}
