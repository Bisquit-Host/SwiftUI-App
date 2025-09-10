import ScrechKit

struct GaugeRegular: View {
    @Environment(\.colorScheme) private var appearance
    
    var name: StatsType = .cpu
    var value, limit: Double
    var isRedacted = false
    
    private let gradient = Gradient(colors: [.mint, .orange, .red])
    
    var body: some View {
        Group {
            switch name {
            case .cpu:
                Gauge(value: value, in: 0...limit) {
                    titleLabel
                } currentValueLabel: {
                    valueLabel
                        .foregroundStyle(appearance == .dark ? .white : .black)
                }
                
            case .ram, .ssd:
                Gauge(value: value / pow(1024, 2), in: 0...limit) {
                    titleLabel
                } currentValueLabel: {
                    valueLabel
                        .foregroundStyle(appearance == .dark ? .white : .black)
                }
            }
        }
        .gaugeStyle(.accessoryCircular)
        .tint(gradient)
    }
    
    private var titleLabel: some View {
        Text(name.rawValue.uppercased())
            .foregroundStyle(appearance == .dark ? .white : .black)
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
        .redacted(isRedacted)
    }
}

#Preview {
    GaugeRegular(value: 0.5, limit: 1)
}
