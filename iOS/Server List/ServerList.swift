import ScrechKit
import Vortex

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView(showsIndicators: false) {
            ServerListTips()
                .frame(maxWidth: 440)
            
            ServerListGrid(vm.filteredServers)
        }
        .navigationTitle("Servers")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .animation(.default, value: vm.servers)
        .searchable(text: $vm.searchField)
        .safariCover($vm.showBilling, url: "https://my.bisquit.host")
        .overlay {
            if isBoundaryDay && !reduceMotion {
                VortexView(.slowSnow.makeUniqueCopy()) {
                    Circle()
                        .fill(.white.opacity(0.8))
                        .frame(width: 24)
                        .blur(radius: 5)
                        .tag("circle")
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
        }
        .background {
            if !isBoundaryDay && !reduceMotion {
                BisquitFall()
            }
        }
        .background(BackgroundImage())
        .serverListToolbar()
        .onFirstAppear {
            vm.loadCachedServers()
        }
        .refreshableTask {
            await vm.fetchServers(store.adminServerList)
            store.updateServers.toggle()
        }
        .onChange(of: vm.searchField) {
            search()
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
            NavigationStack {
                Discover()
            }
        }
        .onGamepadPressed(.menu, cooldown: 1) {
            if !vm.sheetDiscover {
                nav.navigate(.toSettings)
            }
        }
    }
    
    private var isBoundaryDay: Bool {
        let calendar = Calendar.current.dateComponents([.month, .day], from: Date())
        
        guard let month = calendar.month, let day = calendar.day else {
            return false
        }
        
        return (month == 12 && day == 31) || (month == 1 && day == 1)
    }
    
    private func search() {
        guard !(1...2).contains(vm.searchField.count) else {
            return
        }
        
        Task {
            await vm.fetchServers(store.adminServerList, searchPrompt: vm.searchField)
        }
        
        store.updateServers.toggle()
    }
}

#Preview {
    NavigationStack {
        ServerList()
    }
    .darkSchemePreferred()
    .environment(ServerListVM())
    .environment(NavState())
    .environmentObject(ValueStore())
}
