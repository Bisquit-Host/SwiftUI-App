import Charts
import ScrechKit
import PteroNet

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
                
                HStack(spacing: 8) {
                    Text(Converter.millisecondsToTime(vm.uptime))
                        .caption2()
                        .secondary()
                        .monospacedDigit()
                }
            }
            
            if vm.serverState == .offline {
                ContentUnavailableView {
                    Label("Server is disabled", systemImage: "bolt.slash")
                } description: {
                    Text("Start the server to gather metrics")
                } actions: {
                    Button("Start", systemImage: "play.fill", action: startServer)
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
            } else if vm.cpuHistory.isEmpty {
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
                    title: "CPU",
                    value: percentText(vm.cpuUsage, limit: 100),
                    absolute: cpuAbsoluteText,
                    color: .blue,
                    samples: cpuSamples
                )
                
                ResourceGraphCard(
                    title: "RAM",
                    value: percentText(vm.ramUsage, limit: ramLimit),
                    absolute: ramAbsoluteText,
                    color: .green,
                    samples: ramSamples
                )
                
                ResourceGraphCard(
                    title: "SSD",
                    value: percentText(vm.diskUsage, limit: diskLimit),
                    absolute: diskAbsoluteText,
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
    
    private func startServer() {
        Task {
            await vm.changePower(.start)
        }
    }
}

private struct ResourceGraphCard: View {
    let title: String
    let value: String
    let absolute: String
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
                        .monospacedDigit()
                }
                
                Spacer()
                
                Text(absolute)
                    .footnote()
                    .tertiary()
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            
            Chart {
                RuleMark(y: .value("Baseline", 100))
                    .foregroundStyle(.gray.opacity(0.35))
                    .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round, dash: [4, 4]))
                
                ForEach(samples) { sample in
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
