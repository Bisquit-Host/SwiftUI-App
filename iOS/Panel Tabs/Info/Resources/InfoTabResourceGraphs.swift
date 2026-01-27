import Charts
import PteroNet
import SwiftUI

struct InfoTabResourceGraphs: View {
    @Environment(PanelVM.self) private var vm
    
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
            HStack {
                Text("Resource Graphs")
                    .footnote()
                    .secondary()
                
                Spacer()
                
                if vm.serverState == .offline {
                    Text("Offline")
                        .caption2()
                        .tertiary()
                }
            }
            
            if vm.cpuHistory.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "waveform.path.ecg")
                        .tertiary()
                    
                    Text("Waiting for metrics")
                        .footnote()
                        .secondary()
                }
                .frame(maxWidth: .infinity, minHeight: 140)
            } else {
                ResourceGraphCard(
                    title: "Processor",
                    value: percentText(vm.cpuUsage, limit: 100),
                    color: .blue,
                    samples: cpuSamples
                )
                
                ResourceGraphCard(
                    title: "Memory",
                    value: percentText(vm.ramUsage, limit: ramLimit),
                    color: .green,
                    samples: ramSamples
                )
                
                ResourceGraphCard(
                    title: "Storage",
                    value: percentText(vm.diskUsage, limit: diskLimit),
                    color: .orange,
                    samples: diskSamples
                )
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
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
}

private struct ResourceGraphCard: View {
    let title: String
    let value: String
    let color: Color
    let samples: [UsageSample]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .footnote()
                        .secondary()
                    
                    Text(value)
                        .title3(.bold, design: .rounded)
                }
                
                Spacer()
                
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
            
            Chart(samples) { sample in
                AreaMark(
                    x: .value("Time", sample.timestamp),
                    y: .value("Value", sample.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [color.opacity(0.35), color.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Time", sample.timestamp),
                    y: .value("Value", sample.value)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: 0...100)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 60)
        }
        .padding(10)
        .background(.thinMaterial, in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.18), lineWidth: 1)
        }
    }
}

#Preview {
    InfoTabResourceGraphs(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(PanelVM(""))
}
