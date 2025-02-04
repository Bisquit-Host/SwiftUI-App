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
        .environment(vm)
        //        .searchable(text: $searchField)
        .navigationBarBackButtonHidden()
        //        .background {
        //            BisquitFall()
        //        }
        .refreshableTask {
            vm.fetchServers(store.adminServerList)
            store.updateServers.toggle()
        }
        .onChange(of: searchField) { _, search in
            withAnimation {
                vm.searchField = search
            }
        }
        .safeAreaInset(edge: .bottom) {
            ServerListFilter($vm.filterBySuspended)
                .padding(.bottom)
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(vm)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                SFButton("sparkles") {
                    vm.sheetDiscover = true
                }
                .padding(.leading)
                
                TopbarGridButton()
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
#warning("iMessage: Full screen button")
                //                                Button("Test") {
                //                                    test = true
                //                                }
                
                TopbarAdminButton {
                    vm.fetchServers(store.adminServerList)
                }
                
                SettingsButton()
                    .environment(vm)
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
                vm.fetchServers(store.adminServerList)
            }
        }
        .alert("Unknown Error", isPresented: $vm.alertError) {
            
        } message: {
            Text("The list of servers couldn't be loaded. Check your internet connection or contact support")
        }
        .fullScreenCover(isPresented: $test) {
            ServerListGrid(vm.filteredServers)
                .padding(4)
                .padding(.top, 60)
        }
    }
}

#Preview {
    NavigationView {
        ServerList()
    }
    .environment(ServerListVM())
    .environmentObject(ValueStore())
}
