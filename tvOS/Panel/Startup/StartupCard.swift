import SwiftUI
import Calagopus

struct StartupCard: View {
    private let variable: CalagopusServerVariable
    
    init(_ variable: CalagopusServerVariable) {
        self.variable = variable
    }
    
    @State private var newValue = ""
    @State private var boolValue = false
    
    private var isBooleanVariable: Bool {
        variable.rules.joined(separator: "|").localizedStandardContains("boolean")
    }
    
    var body: some View {
        Section(variable.name) {
            Text(variable.description ?? "")
                .secondary()
            
            if isBooleanVariable {
                Toggle(isOn: $boolValue) {
                    Text(boolValue ? "Enabled" : "Disabled")
                }
                    .disabled(!variable.isEditable)
                    .onChange(of: boolValue) { _, newValue in
                        self.newValue = Self.booleanString(for: newValue, template: variable.value)
                    }
            } else {
                TextField("Variable", text: $newValue)
                    .disabled(!variable.isEditable)
            }
            
            Divider()
        }
        .task {
            newValue = Self.currentValue(for: variable)
            if isBooleanVariable {
                boolValue = Self.booleanValue(for: Self.currentValue(for: variable))
            }
        }
        .onChange(of: variable.value) { _, newValue in
            let currentValue = newValue
            self.newValue = currentValue
            if isBooleanVariable {
                boolValue = Self.booleanValue(for: currentValue)
            }
        }
    }
    
    private static func booleanValue(for value: String) -> Bool {
        switch value.lowercased() {
        case "1", "true", "yes", "on":
            return true
        default:
            return false
        }
    }
    
    private static func booleanString(for value: Bool, template: String) -> String {
        let trimmed = template.trimmingCharacters(in: .whitespacesAndNewlines)
        let usesNumeric = Int(trimmed) != nil
        return usesNumeric ? (value ? "1" : "0") : (value ? "true" : "false")
    }
    
    private static func currentValue(for variable: CalagopusServerVariable) -> String {
        variable.value
    }
}

//#Preview {
//    StartupCard()
//        .darkSchemePreferred()
//}
