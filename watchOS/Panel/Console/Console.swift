import ScrechKit

struct Console: View {
    @Environment(PanelVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            ForEach(vm.messages, id: \.self) {
                ConsoleMessage($0)
            }
            .padding(.vertical)
        }
        .navigationTitle("Console")
    }
}

#Preview {
    NavigationStack {
        Console()
    }
    .darkSchemePreferred()
    .environment(PanelVM(""))
}
