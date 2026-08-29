import SwiftUI
import Charts

struct VDSNetworkChart: View {
    let input: [CloudServiceNetworkPoint]
    let output: [CloudServiceNetworkPoint]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Network")
                .headline()
            
            Chart {
                ForEach(input) {
                    LineMark(x: .value("Time", $0.timestamp), y: .value("In", $0.value))
                        .foregroundStyle(.blue)
                }
                
                ForEach(output) {
                    LineMark(x: .value("Time", $0.timestamp), y: .value("Out", $0.value))
                        .foregroundStyle(.orange)
                }
            }
            .frame(height: 180)
            .chartXAxis(.hidden)
        }
    }
}
