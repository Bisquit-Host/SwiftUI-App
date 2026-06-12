import SwiftUI
import PteroNet

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
                .font(.caption)
                .foregroundStyle(.secondary)
            
            LabeledContent("Value") {
                Text(currentValue)
                    .font(.caption.monospaced())
                    .multilineTextAlignment(.trailing)
            }
            
            LabeledContent("Variable") {
                Text(variable.envVariable)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
    }
}
