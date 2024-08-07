import ScrechKit
import StoreKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    @State private var searchField = ""
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView(showsIndicators: false) {
            ServerListGrid(vm.filteredServers)
                .padding(4)
                .padding(.bottom, 70)
        }
        .environment(vm)
        .searchable(text: $searchField)
        .navigationBarBackButtonHidden()
        .background {
            BisquitFall()
        }
        .refreshable {
            vm.fetchServers(settings.adminServerList)
            settings.updateServers.toggle()
        }
        .onChange(of: searchField) { _, search in
            withAnimation {
                vm.searchField = search
            }
        }
        .overlay(alignment: .bottomLeading) {
            ServerListFilter($vm.filterBySuspended)
                .environment(vm)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                SFButton("sparkles") {
                    vm.sheetDiscover = true
                }
                
                TopbarGridButton()
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                TopbarAdminButton {
                    vm.fetchServers(settings.adminServerList)
                }
                
                SettingsButton()
                    .environment(vm)
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
                vm.fetchServers(settings.adminServerList)
            }
        }
        .alert("Unknown Error", isPresented: $vm.alertError) {
            
        } message: {
            Text("The list of servers couldn't be loaded. Check your internet connection or contact support")
        }
    }
}

#Preview {
    NavigationView {
        ServerList()
    }
    .environment(ServerListVM())
    .environment(NavState())
    .environmentObject(SettingsStorage())
}
