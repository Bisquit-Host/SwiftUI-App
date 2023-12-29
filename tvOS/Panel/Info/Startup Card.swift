import SwiftUI
import PteroNet

struct StartupCard: View {
    
    private let variable: StartupVariable
    
    init(_ variable: StartupVariable) {
        self.variable = variable
    }
    
    @State private var newValue = ""
    
    var body: some View {
        Section(variable.name) {            
            Text(variable.description)
                .foregroundStyle(.secondary)
            
            TextField("Variable", text: $newValue)
                .disabled(!variable.isEditable)
            
            Divider()
        }
        .task {
            newValue = variable.serverValue
        }
    }
}

//#Preview {
//    StartupCard()
//}
