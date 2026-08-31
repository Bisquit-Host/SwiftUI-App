import SwiftUI

struct VDSMonitoringSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    var body: some View {
        ServiceSectionCard("Monitoring") {
            if let charts = vm.charts, charts.hasGraphData {
                Group {
                    if !charts.cpu.isEmpty {
                        VDSCPUChart(points: charts.cpu)
                    }
                    
                    if !charts.memory.isEmpty {
                        VDSMemoryChart(points: charts.memory)
                    }
                    
                    if charts.hasNetworkGraphData {
                        VDSNetworkChart(input: charts.networkInput, output: charts.networkOutput)
                    }
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

private extension CloudServiceCharts {
    var hasGraphData: Bool {
        !cpu.isEmpty || !memory.isEmpty || hasNetworkGraphData
    }
    
    var hasNetworkGraphData: Bool {
        !networkInput.isEmpty || !networkOutput.isEmpty
    }
}
