import SwiftUI
import WidgetKit

struct SystemSmallWidgetView: View {
    var entry: Provider.Entry
    
    private let gradient = Gradient(colors: [.mint, .orange, .red])
    
    var body: some View {
        VStack {
            //        if ConfigurationAppIntent().serverId.isEmpty {
            //            VStack {
            //                Image(systemName: "terminal")
            //                    .title()
            //                    .padding(5)
            //
            //                Text("Long press to setup")
            //                    .multilineTextAlignment(.center)
            //            }
            //            .semibold()
            //
            //        } else {
            Text("Test Server")
                .lineLimit(1)
            
            Text(entry.cpuUsage, format: .number)
                .footnote()
            
            Spacer()
            
            HStack {
                Group {
                    Gauge(value: entry.cpuUsage, in: 0...10) {
                        Text("CPU")
                    } currentValueLabel: {
                        Text(entry.cpuUsage, format: .number)
                    }
                    
                    Gauge(value: entry.ramUsage, in: 0...10) {
                        Text("RAM")
                    } currentValueLabel: {
                        Text(entry.ramUsage, format: .number)
                    }
                }
                .tint(gradient)
                .gaugeStyle(.accessoryCircular)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(alignment: .center) {
                    Text("Updated")
                        .foregroundStyle(.tertiary)
                    
                    Text(Date(), style: .time)
                        .foregroundStyle(.secondary)
                }
                .caption2()
                
                Spacer()
                
                Button(intent: ConfigurationAppIntent()) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .semibold()
                }
                
                Spacer()
            }
        }
        .containerBackground(.ultraThinMaterial, for: .widget)
    }
}

#Preview(as: .systemSmall) {
    SystemSmallWidget()
} timeline: {
    SystemSmallEntry(date: .now,
                     cpuUsage: 0,
                     ramUsage: 0)
    
    SystemSmallEntry(date: .now,
                     cpuUsage: 0,
                     ramUsage: 0)
}
