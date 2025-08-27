import ScrechKit
import StoreKit

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var store: ValueStore

    @State private var fullScreenCover = false

    var body: some View {
        @Bindable var vm = vm

        ScrollView(showsIndicators: false) {
            ServerListGrid(vm.filteredServers)
                .padding(4)
                .padding(.top, 60)
        }
        .navigationBarBackButtonHidden()
        .searchable(text: $vm.searchField)
        //        .background(BisquitFall())
        .refreshableTask {
            await vm.fetchServers(store.adminServerList)
            store.updateServers.toggle()
        }
        .onChange(of: vm.searchField) {
            guard !(1...2).contains(vm.searchField.count) else {
                return
            }

            Task {
                await vm.fetchServers(store.adminServerList, searchPrompt: vm.searchField)
            }

            store.updateServers.toggle()
        }
        .safeAreaInset(edge: .bottom) {
            ServerListFilter()
                .padding(.bottom)
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(vm)
        }
        .overlay {
            if vm.filteredServers.isEmpty, !vm.searchField.isEmpty {
                ContentUnavailableView.search(text: vm.searchField)
            }
        }
        .fullScreenCover($fullScreenCover) {
            ServerListGrid(vm.filteredServers)
                .padding(4)
                .padding(.top, 60)
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
                //    fullScreenCover = true
                //}

                ServerListAdminButton()

                SettingsButton()
                    .padding(.trailing)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ServerList()
    }
    .environment(ServerListVM())
    .environmentObject(ValueStore())
}
