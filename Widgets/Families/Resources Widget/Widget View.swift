import SwiftUI
import WidgetKit
import PteroNet

struct CryptoPriceWidgetView: View {
    private let entry: ResourcesUsageEntry
    
    init(_ entry: ResourcesUsageEntry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(entry.name)
                    .title(.bold)
                
                Text(entry.id)
                    .footnote()
            }
            
            Text(entry.state)
                .caption2()
                .padding(.bottom, 8)
            
            Text(entry.test?.usage.cpu.description ?? "Error")
            
            Text(entry.date, format: .dateTime.minute().second())
                .footnote()
            
            Button("Update", intent: RefreshIntent())
            
            //            CircularGauge(
            //                param: "CPU",
            //                value: vm.cpuUsage,
            //                limit: limits.cpu,
            //                isRedacted: vm.isLoading
            //            )
            //
            //            CircularGauge(
            //                param: "RAM",
            //                value: vm.ramUsage,
            //                limit: limits.memory,
            //                isRedacted: vm.isLoading
            //            )
            //
            //            CircularGauge(
            //                param: "SSD",
            //                value: vm.diskUsage,
            //                limit: limits.disk,
            //                isRedacted: vm.isLoading
            //            )
        }
        .containerBackground(for: .widget) {}
    }
}

#Preview(as: .systemMedium) {
    SomeNewWidget()
} timeline: {
    ResourcesUsageEntry(
        date: .now,
        name: "Preview",
        id: "bf7903cc",
        state: "Running",
        test: .init(
            state: "Running",
            usage: .init(
                memory: 1024,
                cpu: 200,
                disk: 1024
            ))
    )
}
