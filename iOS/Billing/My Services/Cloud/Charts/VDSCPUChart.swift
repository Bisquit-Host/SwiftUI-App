import SwiftUI
import Charts

struct VDSCPUChart: View {
    let points: [CloudServiceCPUPoint]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("CPU")
                .headline()
            
            Chart(points) {
                LineMark(x: .value("Time", $0.timestamp), y: .value("CPU", $0.cpuLoad))
                    .foregroundStyle(.blue)
            }
            .frame(height: 180)
            .chartYScale(domain: 0...100)
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }
}
