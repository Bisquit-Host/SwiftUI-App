import ScrechKit
import Calagopus

struct StartupCard: View {
    private let variable: CalagopusServerVariable
    
    init(_ variable: CalagopusServerVariable) {
        self.variable = variable
    }
    
    private var currentValue: String {
        variable.value
    }
    
    var body: some View {
        Section(variable.name) {
            Text(variable.description ?? "")
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
