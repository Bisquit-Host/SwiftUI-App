import SwiftUI
import Algorithms

struct LogList: View {
    @Environment(LogVM.self) private var vm
    
    @State private var searchField = ""
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        
        formatter.formatOptions = [
            .withInternetDateTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime
        ]
        
        return formatter
    }()
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            let logsByMonth = vm.searchedLogs.chunked { lhs, rhs in
                let date1 = dateFormatter.date(from: lhs.timestamp)
                let date2 = dateFormatter.date(from: rhs.timestamp)
                
                return Calendar.current.component(.month, from: date1!) == Calendar.current.component(.month, from: date2!)
            }
            
            ForEach(logsByMonth.indices, id: \.self) { index in
                let logs = logsByMonth[index]
                
                Section(monthName(for: logs.first!.timestamp)) {
                    ForEach(logs, id: \.id) { log in
                        LogCard(log)
                    }
                }
            }
        }
        .navigationTitle("Server logs")
        .toolbarTitleDisplayMode(.inline)
        .searchable(text: $vm.searchField)
        .overlay {
            if vm.searchedLogs.isEmpty {
                ContentUnavailableView.search(text: vm.searchField)
            }
        }
        .refreshableTask {
            vm.fetchLogs()
        }
    }
    
    private func monthName(for isoTimestamp: String) -> String {
        guard let date = dateFormatter.date(from: isoTimestamp) else {
            return "Unknown Month"
        }
        
        return DateFormatter()
            .monthSymbols[Calendar.current.component(.month, from: date) - 1]
    }
}

#Preview {
    NavigationView {
        LogList()
            .environment(LogVM(""))
    }
}
