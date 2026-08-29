import SwiftUI
import Charts

struct VDSMemoryChart: View {
    let points: [CloudServiceMemoryPoint]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("RAM")
                .headline()
            
            Chart(points) {
                LineMark(x: .value("Time", $0.timestamp), y: .value("RAM", $0.memoryUsage))
                    .foregroundStyle(.green)
            }
            .frame(height: 180)
            .chartXAxis(.hidden)
        }
    }
}
