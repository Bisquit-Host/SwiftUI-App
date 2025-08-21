import ScrechKit
import StoreKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @State private var searchField = ""
    @State private var test = false
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView(showsIndicators: false) {
            ServerListGrid(vm.filteredServers)
                .padding(4)
                .padding(.top, 60)
        }
        .navigationBarBackButtonHidden()
        //        .searchable(text: $searchField)
        //        .background(BisquitFall())
        .refreshableTask {
            await vm.fetchServers(store.adminServerList)
            store.updateServers.toggle()
        }
        .onChange(of: searchField) { _, search in
            withAnimation {
                vm.searchField = search
            }
        }
        .safeAreaInset(edge: .bottom) {
            ServerListFilter()
                .padding(.bottom)
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(vm)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                SFButton("sparkles") {
                    vm.sheetDiscover = true
                }
                .padding(.leading)
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
#warning("iMessage: Full screen button")
                //Button("Test") {
                //    test = true
                //}
                
                ServerListAdminButton()
                
                SettingsButton()
                    .padding(.trailing)
            }
        }
        .overlay {
            if vm.filteredServers.isEmpty, !vm.searchField.isEmpty {
                ContentUnavailableView.search(text: vm.searchField)
            }
        }
        .sheet($vm.sheetGuide) {
            Guide()
        }
        .sheet($vm.sheetDiscover) {
            Discover()
        }
        .sheet($vm.sheetKeyStorage) {
            CloudKeys($vm.apiKey) {
                Task {
                    await vm.fetchServers(store.adminServerList)
                }
            }
        }
        .fullScreenCover($test) {
            ServerListGrid(vm.filteredServers)
                .padding(4)
                .padding(.top, 60)
        }
    }
}

#Preview {
    NavigationStack {
        ServerList()
    }
    .darkSchemePreferred()
    .environment(ServerListVM())
    .environmentObject(ValueStore())
}
