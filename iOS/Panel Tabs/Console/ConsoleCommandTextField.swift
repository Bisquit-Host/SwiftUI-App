import ScrechKit

struct ConsoleCommandTextField: View {
    @Environment(ConsoleVM.self) private var vm
    
    let onSubmit: () -> Void
    
    var body: some View {
        @Bindable var vm = vm
        
        TextField("Type a command", text: $vm.command)
            .monospaced()
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onSubmit(onSubmit)
    }
}

#Preview {
    ConsoleCommandTextField(onSubmit: {})
        .darkSchemePreferred()
        .environment(ConsoleVM(""))
}
