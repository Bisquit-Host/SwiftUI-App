import ScrechKit
import AlertKit
import PteroNet

struct StartupCard: View {
    private var vm: StartupVM
    private let server: ServerListAttributes
    private let variable: PNStartupVariableAttributes
    
    init(_ server: ServerListAttributes,
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
                    value = variable.default_value
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .semibold()
                }
            }
            
            Text(variable.description)
                .footnote()
                .foregroundStyle(.secondary)
            
            TextField("Type here", text: $value)
                .disabled(!variable.is_editable)
            
            Text(variable.rules)
        }
        .task {
            value = variable.server_value
        }
        .onChange(of: value) { _, newValue in
            let rulesArray = variable.rules.split(separator: "|")
            
            guard let rule = rulesArray.first, rule == "required" else {
                vm.changeVariable(variable: variable.env_variable, newValue: newValue)
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
                variable: variable.env_variable,
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
                env_variable: "SOME_VARIABLE",
                default_value: "Default Value",
                server_value: "Current Value",
                rules: "",
                is_editable: true
            )
        )
    }
}
