import ScrechKit

struct ConsoleClassicInputBar: View {
    @Environment(ConsoleVM.self) private var vm
    @Environment(\.panelCodexChatPresented) private var isPresented
    
    let sendCommand: () -> Void
    
    var body: some View {
        @Bindable var vm = vm
        
        HStack {
            PowerSwitch()
                .padding(10)
                .background(.ultraThinMaterial, in: .circle)
                .overlay {
                    Circle()
                        .stroke(.gray.opacity(0.25), lineWidth: 1)
                }
                .padding(.trailing, 10)
            
            ConsoleCommandTextField(onSubmit: sendCommand)
            
            if !vm.command.isEmpty {
                Button("Clear", systemImage: "delete.left") {
                    vm.command = ""
                }
                .secondary()
            }
            
            if vm.command.isEmpty {
                PanelCodexChatButton(isPresented)
                    .scaleEffect(2)
            }
        }
        .animation(.default, value: vm.command)
        .padding()
        .background(.ultraThinMaterial)
    }
}

#Preview {
    ConsoleClassicInputBar(sendCommand: {})
        .darkSchemePreferred()
        .environment(ConsoleVM(""))
}
