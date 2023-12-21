import ScrechKit
import AlertKit
import PteroNet

struct StartupCard: View {
    private var vm: StartupVM
    private let server: ServerAttributes
    private let variable: PNStartupVariableAttributes
    
    init(_ server: ServerAttributes,
         variable: PNStartupVariableAttributes,
         model: StartupVM = StartupVM("")
    ) {
        self.server = server
        self.variable = variable
        self.vm = StartupVM(server.id)
    }
    
    @State private var value = ""
    
    var body: some View {
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
                .disabled(!variable.isEditable)
            
            Text(variable.rules)
        }
        .task {
            value = variable.serverValue
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

#Preview {
    List {
        StartupCard(
            sampleJSON(.serverListAttributes),
            variable: .init(
                name: "Variable Name",
                description: "Some variable does something",
                envVariable: "SOME_VARIABLE",
                defaultValue: "Default Value",
                serverValue: "Current Value",
                rules: "",
                isEditable: true
            )
        )
    }
}
