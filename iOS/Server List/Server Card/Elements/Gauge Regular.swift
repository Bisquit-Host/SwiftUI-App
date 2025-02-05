import ScrechKit

struct RegularGauge: View {
    private let name: StatsType
    private var value, limit: Double
    private var isRedacted: Bool
    
    private let gradient = Gradient(colors: [.mint, .orange, .red])
    
    init(
        name: StatsType = .cpu,
        value: Double,
        limit: Double,
        isRedacted: Bool = false
    ) {
        self.name = name
        self.value = value
        self.limit = limit
        self.isRedacted = isRedacted
    }
    
    var body: some View {
        Group {
            switch name {
            case .cpu:
                Gauge(value: value, in: 0...limit) {
                    titleLabel
                } currentValueLabel: {
                    valueLabel
                }
                
            case .ram, .ssd:
                Gauge(value: value / pow(1024, 2), in: 0...limit) {
                    titleLabel
                } currentValueLabel: {
                    valueLabel
                }
            }
        }
        .gaugeStyle(.accessoryCircular)
        .tint(gradient)
    }
    
    private var titleLabel: some View {
        Text(name.rawValue.uppercased())
            .foregroundColor(.primary)
    }
    
    private var valueLabel: some View {
        Group {
            switch name {
            case .cpu:
                if value == 0 {
                    Text("-")
                } else {
                    Text(String(format: "%.0f", value) + "%")
                }
                
            case .ram, .ssd:
                Text(formatBytes(value).replacing(" ", with: ""))
            }
        }
        .foregroundColor(.primary)
        .redacted(isRedacted)
    }
}

#Preview {
    RegularGauge(value: 0.5, limit: 1)
}
