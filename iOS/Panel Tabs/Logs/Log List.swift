import SwiftUI
import Algorithms
import PteroNet

struct LogList: View {
    @Environment(LogVM.self) private var vm
    
    @State private var searchField = ""
    
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
        .toolbarTitleDisplayMode(.inline)
        .ornamentDismissButton()
        .searchable(text: $vm.searchField)
        .transparentList()
        .refreshableTask {
            vm.fetchLogs()
        }
        .overlay {
            if vm.searchedLogs.isEmpty {
                ContentUnavailableView.search(text: vm.searchField)
            }
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
