import ScrechKit
import StoreKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    @State private var searchField = ""
    
    var body: some View {
        @Bindable var binding = vm
        
        ScrollView(showsIndicators: false) {
            ServerListTopbar($binding.filterBySuspended)
            
            if vm.filteredServers.isEmpty, !vm.searchField.isEmpty {
                ContentUnavailableView("No Results for \"\(vm.searchField)\"",
                                       systemImage: "externaldrive",
                                       description: Text("Check the spelling or try another search")
                )
            } else {
                ServerListGrid(vm.filteredServers)
                    .padding(4)
            }
            
            if !vm.filteredServers.isEmpty {
                ServerListFooter()
            }
        }
        .environment(vm)
        .searchable(text: $searchField)
        .navigationTitle("Bisquit.Host")
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                SFButton("sparkles") {
                    vm.sheetDiscover = true
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                SettingsButton()
                    .environment(vm)
            }
        }
        .sheet($binding.sheetGuide) {
            Guide()
        }
        .sheet($binding.sheetDiscover) {
            Discover()
        }
        .sheet($binding.sheetKeyStorage) {
            CloudKeys($binding.apiKey) {
                vm.fetchServers(settings.adminServerList)
            }
        }
        .alert("Unknown Error", isPresented: $binding.alertError) {} message: {
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
