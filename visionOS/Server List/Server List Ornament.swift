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
                Label("Switch Account", image: "arrow.trianglehead.2.clockwise.rotate.90")
            }
            
            //            Button {
            //                vm.sheetSettings = true
            //            } label: {
            //                Label("Settings", image: "gear")
            //            }
        } label: {
            Image(systemName: "gear")
        }
    }
}

#Preview {
    @Previewable @State var sheetSettings = false
    
    ServerListOrnament($sheetSettings)
        .padding()
        .environment(ServerListVM())
}
