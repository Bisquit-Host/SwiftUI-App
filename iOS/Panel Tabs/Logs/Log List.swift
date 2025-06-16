import SwiftUI
import PteroNet

struct LogList: View {
    @Environment(LogVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            LogTopbar()
            
            ForEach(vm.logsByMonth, id: \.self) { logs in
                let month = vm.monthName(for: logs.first!.timestamp)
                
                Section {
                    ForEach(logs) { log in
                        LogCard(log)
                    }
                } header: {
                    Text(month)
                        .title3(.semibold, design: .rounded)
                        .foregroundStyle(.primary)
                }
            }
        }
        .navigationTitle("Logs")
        //        .searchToolbarBehavior(.minimize)
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
        //        .searchable(text: $vm.searchPrompt)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton {
                    dismiss()
                }
            }
#if !os(watchOS) && !os(tvOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
            
            //            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            //
            //            ToolbarSpacer(.fixed, placement: .bottomBar)
            
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
    NavigationView {
        LogList()
    }
    .environment(LogVM(""))
}
