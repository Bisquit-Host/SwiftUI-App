import ScrechKit

struct ConsoleClassicInputBar: View {
    @Environment(ConsoleVM.self) private var vm
    @Environment(\.panelCodexChatPresented) private var isPresented
    
    let sendCommand: () -> Void
    
    var body: some View {
        @Bindable var vm = vm
        
        HStack {
            PowerSwitch()
                .frame(45)
                .glassEffect(in: .circle)
                .padding(.trailing, 10)
            
            ConsoleCommandTextField(onSubmit: sendCommand)
            
            if !vm.command.isEmpty {
                Button("Clear", systemImage: "delete.left") {
                    vm.command = ""
                }
                .secondary()
                .labelStyle(.iconOnly)
            }
            
            if vm.command.isEmpty {
                PanelCodexChatButton(isPresented)
                    .scaleEffect(1.6)
                    .frame(45)
                    .glassEffect(in: .circle)
                    .padding(.leading, 10)
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
