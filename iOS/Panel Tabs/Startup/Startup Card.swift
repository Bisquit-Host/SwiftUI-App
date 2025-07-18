import ScrechKit
import AlertKit
import PteroNet

struct StartupCard: View {
    private var vm: StartupVM
    private let server: ServerAttributes
    private let variable: StartupVariable
    
    init(_ server: ServerAttributes, variable: StartupVariable) {
        self.server = server
        self.variable = variable
        self.vm = StartupVM(server.id)
        value = variable.serverValue ?? ""
    }
    
    @State private var value = ""
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack {
                    Text(variable.name)
                    
                    Spacer()
                    
                    Menu {
                        Button("Reset to default", systemImage: "arrow.counterclockwise") {
                            value = variable.defaultValue
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .semibold()
                            .foregroundStyle(.foreground)
                    }
                }
                
                Text(variable.description)
                    .footnote()
                    .secondary()
                
                TextField("Type here", text: $value)
                    .autocorrectionDisabled()
                    .disabled(!variable.isEditable)
            }
            
            if value != variable.serverValue {
                Button("Save") {
                    save()
                }
                .foregroundStyle(.foreground)
            }
        }
    }
    
    private func save() {
        Task {
            await vm.updateVariable(
                key: variable.envVariable,
                value: value
            ) {
                value = variable.serverValue ?? ""
            }
        }
    }
}

//#Preview {
//    List {
//        StartupCard(
//            sampleJSON(.serverListAttributes),
//            variable: StartupVariable(
//                name: "Variable Name",
//                description: "Some variable does something",
//                envVariable: "SOME_VARIABLE",
//                defaultValue: "Default Value",
//                serverValue: "Current Value",
//                rules: "",
//                isEditable: true
//            )
//        )
//    }
//}
