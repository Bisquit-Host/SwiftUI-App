import ScrechKit
import Calagopus

struct LogList: View {
    @Environment(LogVM.self) private var vm
#if os(iOS)
    @Environment(\.agentChatPresented) private var isPresented
    @Environment(\.panelAIAgentEnabled) private var isAIAgentEnabled
    @Environment(\.panelToolbarButtonsVisible) private var toolbarButtonsVisible
#endif
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            LogTopbar()
            
            ForEach(vm.logsByMonth, id: \.self) { logs in
                let month = vm.monthName(for: logs.first!.timestamp)
                
                Section {
                    ForEach(logs) {
                        LogCard($0)
                    }
                } header: {
                    Text(month)
                        .title3(.semibold, design: .rounded)
                        .foregroundStyle(.primary)
                }
            }
        }
        .panelNavigationTitle("Logs")
        .searchable(text: $vm.searchPrompt)
        .ornamentDismissButton()
        .animation(.default, value: vm.filteredLogs)
        .task {
            grantAchievement("open_server_logs")
        }
        .refreshableTask {
            await vm.fetchLogs()
        }
#if os(iOS)
        .task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
                if !System.lowPowerMode {
                    await vm.fetchLogs()
                }
            }
        }
#endif
        .overlay {
            if vm.searchedLogs.isEmpty {
                if vm.searchPrompt.isEmpty {
                    ContentUnavailableView("No recent actions have been logged", systemImage: "list.bullet.rectangle.fill")
                } else {
                    ContentUnavailableView.search(text: vm.searchPrompt)
                }
            } else if vm.logs.isEmpty {
                ContentUnavailableView("No recent actions have been logged", systemImage: "list.bullet.rectangle.fill")
            }
        }
        .toolbar {
#if !os(watchOS)
            if !vm.logs.isEmpty {
                PanelToolbarItem(placement: .bottomBar) {
                    LogListFilter()
                }
            }
#endif
            
#if os(iOS)
            ToolbarSpacer(.fixed, placement: .bottomBar)
            
            if toolbarButtonsVisible {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
            }
            
#endif
#if os(iOS)
            if isAIAgentEnabled {
                ToolbarSpacer(.fixed, placement: .bottomBar)

                PanelToolbarItem(placement: .bottomBar) {
                    AgentChatButton(isPresented)
                }
            }
#endif
        }
    }
}

#Preview {
    NavigationStack {
        LogList()
    }
    .darkSchemePreferred()
    .environment(LogVM(""))
}
