import ScrechKit
import PteroNet

struct ConsoleOverlay: View {
    @Environment(ConsoleVM.self) private var vm
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            HStack {
                PowerSwitch()
                
                Spacer()
                
                ConsoleSearch()
                
                InspectorButton($vm.inspectorPresented)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                CommandLine(id)
            }
        }
        .padding()
    }
}

#Preview {
    ConsoleOverlay("")
        .environment(ConsoleVM(""))
}
