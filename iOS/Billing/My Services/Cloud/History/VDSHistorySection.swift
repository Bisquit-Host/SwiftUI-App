import Algorithms
import SwiftUI

struct VDSHistorySection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    var body: some View {
        if vm.history.isEmpty {
            Text("No actions yet")
                .secondary()
                .footnote()
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
        } else {
            ForEach(daySections, id: \.day) { section in
                Section {
                    ForEach(section.items) {
                        VDSHistoryItem($0)
                    }
                } header: {
                    Text(section.title)
                        .textCase(.none)
                }
            }
        }
    }
    
    private var daySections: [DaySection] {
        let calendar = Calendar.current
        
        let sorted = vm.history.sorted {
            ($0.date ?? .distantPast) > ($1.date ?? .distantPast)
        }
        
        return sorted
            .chunked(on: { item in
                guard let date = item.date else { return .distantPast }
                return calendar.startOfDay(for: date)
            })
            .map { day, items in
                DaySection(day: day, items: Array(items))
            }
    }
}

private struct DaySection {
    let day: Date
    let items: [CloudServiceHistoryItem]
    
    var title: String {
        guard day != .distantPast else { return "Unknown" }
        return day.formatted(date: .abbreviated, time: .omitted)
    }
}
