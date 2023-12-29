import ScrechKit
import AlertKit
import PteroNet

struct StartupCard: View {
    private var vm: StartupVM
    private let server: ServerAttributes
    private let variable: StartupVariable
    
    init(_ server: ServerAttributes,
         variable: StartupVariable
    ) {
        self.server = server
        self.variable = variable
        self.vm = StartupVM(server.id)
        value = variable.serverValue
    }
    
    @State private var value: String
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack {
                    Text(variable.name)
                    
                    Spacer()
                    
                    Button {
                        value = variable.defaultValue
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .semibold()
                    }
                }
                
                Text(variable.description)
                    .footnote()
                    .foregroundStyle(.secondary)
                
                TextField("Type here", text: $value)
                    .autocorrectionDisabled()
                    .disabled(!variable.isEditable)
                
                Text(variable.rules)
            }
        }
        .onChange(of: value) { _, newValue in
            let rulesArray = variable.rules.split(separator: "|")
            
            guard let rule = rulesArray.first, rule == "required" else {
                vm.changeVariable(variable: variable.envVariable, newValue: newValue)
                return
            }
            
            if newValue.isEmpty {
                AlertKitAPI.present(
                    title: "Can't be empty",
                    icon: .error,
                    style: .iOS17AppleMusic,
                    haptic: .error
                )
                
                return
            }
            
            vm.changeVariable(
                variable: variable.envVariable,
                newValue: newValue
            )
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
