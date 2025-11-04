import SwiftUI
import PteroNet

struct LogList: View {
    @Environment(LogVM.self) private var vm
    
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
        .navigationTitle("Logs")
        .searchable(text: $vm.searchPrompt)
        .ornamentDismissButton()
        .animation(.default, value: vm.filteredLogs)
        .refreshableTask {
            await vm.fetchLogs()
        }
#if os(iOS)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if !System.lowPowerMode {
                Task {
                    await vm.fetchLogs()
                }
            }
        }
#endif
        .overlay {
            if vm.logs.isEmpty {
                ContentUnavailableView(
                    "No recent actions have been logged",
                    systemImage: "list.bullet.rectangle.fill"
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
#if os(iOS) || os(macOS)
            ToolbarSpacer(.fixed, placement: .bottomBar)
            
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            
            ToolbarSpacer(.fixed, placement: .bottomBar)
#endif
            
#if !os(watchOS) && !os(tvOS)
            if !vm.logs.isEmpty {
                ToolbarItem(placement: .bottomBar) {
                    LogListFilter()
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
