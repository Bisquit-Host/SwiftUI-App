import ScrechKit

struct ServerListOrnament: View {
    @Environment(ServerListVM.self) private var vm
    
    @Binding private var sheetSettings: Bool
    
    init(_ sheetSettings: Binding<Bool>) {
        _sheetSettings = sheetSettings
    }
    
    var body: some View {
        Menu {
            Button {
                vm.sheetKeyStorage = true
            } label: {
                Label("Switch account", image: "key.viewfinder")
            }
        } label: {
            Image(systemName: "gear")
        }
        
        SFButton("gear") {
            sheetSettings = true
        }
        .bold()
    }
}

#warning("ios 18")
//#Preview {
//    ServerListOrnament()
//        .padding()
//        .environment(ServerListVM())
//}
