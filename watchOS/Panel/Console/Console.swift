import ScrechKit

struct Console: View {
    @Environment(PanelVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            ForEach(vm.messages, id: \.self) { message in
                ConsoleMessage(message)
            }
            .padding(.vertical)
        }
        .navigationTitle("Console")
    }
}

#Preview {
    Console()
        .environment(PanelVM(""))
}
