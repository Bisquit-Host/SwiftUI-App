import Charts
import SwiftUI

struct VDSMonitoringSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    var body: some View {
        VDSSectionCard("Monitoring") {
            if let charts = vm.charts {
                Group {
                    Chart(charts.cpu) {
                        LineMark(x: .value("Time", $0.timestamp), y: .value("CPU", $0.cpuLoad))
                            .foregroundStyle(.blue)
                    }
                    .frame(height: 180)
                    .chartYScale(domain: 0...100)
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    
                    Chart(charts.memory) {
                        LineMark(x: .value("Time", $0.timestamp), y: .value("RAM", $0.memoryUsage))
                            .foregroundStyle(.green)
                    }
                    .frame(height: 180)
                    .chartXAxis(.hidden)
                    
                    Chart {
                        ForEach(charts.networkInput) {
                            LineMark(x: .value("Time", $0.timestamp), y: .value("In", $0.value))
                                .foregroundStyle(.blue)
                        }
                        
                        ForEach(charts.networkOutput) {
                            LineMark(x: .value("Time", $0.timestamp), y: .value("Out", $0.value))
                                .foregroundStyle(.orange)
                        }
                    }
                    .frame(height: 180)
                    .chartXAxis(.hidden)
                }
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
            } else {
                Text("No metrics yet")
                    .secondary()
                    .footnote()
                    .opacity(vm.isLoading ? 0.6 : 1)
            }
        }
    }
}
