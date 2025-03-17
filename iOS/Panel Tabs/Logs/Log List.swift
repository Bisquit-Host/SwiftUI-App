import SwiftUI
import PteroNet

struct LogList: View {
    @Environment(LogVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            LogTopbar()
            
            ForEach(vm.logsByMonth.indices, id: \.self) { index in
                let logs = vm.logsByMonth[index]
                
                Section(vm.monthName(for: logs.first!.timestamp)) {
                    ForEach(logs) { log in
                        LogCard(log)
                    }
                }
                .transparentSection()
            }
        }
        .navigationTitle("Server logs")
#if !os(tvOS)
        .toolbarTitleDisplayMode(.large)
#endif
        .toolbarTitleDisplayMode(.inline)
        .ornamentDismissButton()
        .transparentList()
        .refreshableTask {
            vm.fetchLogs()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .footnote(.bold)
                        .frame(width: 35, height: 35)
                        .background(.ultraThinMaterial, in: .circle)
                }
                .foregroundStyle(.primary)
            }
            
#warning("Logs: filter by user")
            //            ToolbarItem(placement: .topBarTrailing) {
            //                Menu {
            //
            //                } label: {
            //                    Image(systemName: "person.crop.circle.badge.plus")
            //                        .foregroundStyle(.foreground)
            //                        .footnote(.bold)
            //                        .frame(width: 35, height: 35)
            //                        .background(.ultraThinMaterial, in: .circle)
            //                }
            //            }
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
