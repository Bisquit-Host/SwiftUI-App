import ScrechKit

struct ServerListOrnament: View {
    @Environment(ServerListVM.self) private var vm
    
    var body: some View {
        SFButton("gear") {
            //            vm.sheetSettings = true FIX
        }
        .bold()
    }
}

#Preview {
    ServerListOrnament()
        .padding()
        .glassBackgroundEffect()
        .environment(ServerListVM())
}
