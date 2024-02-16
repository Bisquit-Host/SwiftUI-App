import ScrechKit

struct ServerListOrnament: View {
    @Environment(ServerListVM.self) private var vm
    
    @State private var sheetIcloud = false
    
    var body: some View {
        Menu {
            Button {
                sheetIcloud = true
            } label: {
                Label("Switch account", image: "key.viewfinder")
            }
        } label: {
            Image(systemName: "gear")
        }
//        SFButton("gear") {
            //            vm.sheetSettings = true FIX
//        }
        .bold()
        .sheet($sheetIcloud) {
            
        }
    }
}

#Preview {
    ServerListOrnament()
        .padding()
        .environment(ServerListVM())
}
