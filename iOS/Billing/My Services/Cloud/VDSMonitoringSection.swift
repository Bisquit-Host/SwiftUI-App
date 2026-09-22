import SwiftUI

struct VDSMonitoringSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    var body: some View {
        ServiceSectionCard("Monitoring") {
            Group {
                VDSCPUChart(points: vm.charts?.cpu ?? [])
                VDSMemoryChart(points: vm.charts?.memory ?? [])
                VDSNetworkChart(
                    input: vm.charts?.networkInput ?? [],
                    output: vm.charts?.networkOutput ?? []
                )
            }
            .padding()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
            .overlay {
                if vm.hasLoadedCharts, !vm.isLoadingCharts, vm.charts?.hasGraphData != true {
                    Text("No metrics yet")
                        .secondary()
                        .footnote()
                }
            }
        }
    }
}

private extension CloudServiceCharts {
    var hasGraphData: Bool {
        !cpu.isEmpty || !memory.isEmpty || !networkInput.isEmpty || !networkOutput.isEmpty
    }
}
