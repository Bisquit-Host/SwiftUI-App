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
                .transparentSection()
            }
        }
        .navigationTitle("Logs")
#if !os(tvOS)
        .toolbarTitleDisplayMode(.large)
#endif
        .toolbarTitleDisplayMode(.inline)
        .ornamentDismissButton()
        .transparentList()
        .animation(.default, value: vm.filteredLogs)
        .refreshableTask {
            vm.fetchLogs()
        }
#if os(iOS)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if !System.lowPowerMode {
                vm.fetchLogs()
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
            ToolbarItem(placement: .topBarLeading) {
                DismissButton {
                    dismiss()
                }
            }
            
#if !os(watchOS) && !os(tvOS)
            if !vm.logs.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
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
            .environment(LogVM(""))
            .environmentObject(ValueStore())
    }
}
