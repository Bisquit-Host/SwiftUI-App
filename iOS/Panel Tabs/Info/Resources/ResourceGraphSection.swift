import ScrechKit
import Calagopus

struct ResourceGraphSection: View {
    @Environment(PanelVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let limits: ServerLimits
    
    init(_ server: ServerAttributes) {
        limits = server.limits
    }
    
    private var ramLimit: Double {
        limits.memory * pow(1024, 2)
    }
    
    private var diskLimit: Double {
        limits.disk
    }
    
    private var cpuSamples: [UsageSample] {
        vm.cpuHistory.map {
            UsageSample(id: $0.id, timestamp: $0.timestamp, value: clampedPercent($0.value, limit: 100))
        }
    }
    
    private var ramSamples: [UsageSample] {
        vm.ramHistory.map {
            UsageSample(id: $0.id, timestamp: $0.timestamp, value: clampedPercent($0.value, limit: ramLimit))
        }
    }
    
    private var diskSamples: [UsageSample] {
        vm.diskHistory.map {
            UsageSample(id: $0.id, timestamp: $0.timestamp, value: clampedPercent($0.value, limit: diskLimit))
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if vm.serverState == .offline {
                ResourceGraphEmptyView()
            } else {
                ResourceGraphSectionUptime()
                
                ResourceGraphCard(
                    title: "CPU",
                    value: percentText(vm.cpuUsage, limit: 100),
                    absolute: cpuAbsoluteText,
                    tint: .blue,
                    samples: cpuSamples
                )
                
                ResourceGraphCard(
                    title: "RAM",
                    value: percentText(vm.ramUsage, limit: ramLimit),
                    absolute: ramAbsoluteText,
                    tint: .green,
                    samples: ramSamples
                )
                
                ResourceGraphCard(
                    title: "SSD",
                    value: percentText(vm.diskUsage, limit: diskLimit),
                    absolute: diskAbsoluteText,
                    tint: .orange,
                    samples: diskSamples
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func percentText(_ usage: Double, limit: Double) -> String {
        guard vm.serverState != .offline, usage.isFinite, limit > 0 else { return "-" }
        
        let ratio = usage / limit * 100
        let clamped = max(0, min(100, ratio))
        
        return "\(Int(clamped.rounded()))%"
    }
    
    private func clampedPercent(_ usage: Double, limit: Double) -> Double {
        guard usage.isFinite, limit > 0 else { return 0 }
        
        let ratio = usage / limit * 100
        
        return max(0, min(100, ratio))
    }
    
    private var cpuAbsoluteText: String {
        let usage = vm.serverState == .offline ? "-" : "\(Int(vm.cpuUsage))%"
        let limit = "\(Int(limits.cpu))%"
        
        return "\(usage) / \(limit)"
    }
    
    private var ramAbsoluteText: String {
        let usage = vm.serverState == .offline ? "-" : formatBytes(vm.ramUsage, countStyle: .memory)
        let limit = formatBytes(limits.memory * pow(1024, 2), countStyle: .memory)
        
        return "\(usage) / \(limit)"
    }
    
    private var diskAbsoluteText: String {
        let usage = vm.serverState == .offline ? "-" : formatBytes(vm.diskUsage * pow(1024, 2))
        let limit = formatBytes(limits.disk * pow(1024, 2), countStyle: .memory)
        
        return "\(usage) / \(limit)"
    }
}

#Preview {
    ResourceGraphSection(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
