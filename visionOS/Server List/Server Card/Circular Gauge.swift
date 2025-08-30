import ScrechKit

struct CircularGauge: View {
    private let param: LocalizedStringKey
    private let value, limit: Double
    private var isRedacted: Bool
    
    init(
        param: LocalizedStringKey,
        value: Double,
        limit: Double,
        isRedacted: Bool
    ) {
        self.param = param
        self.value = value
        self.limit = limit
        self.isRedacted = isRedacted
    }
    
    private var valueLabel: String {
        if value != 0 {
            if param == "CPU" {
                String(Int(value)) + "%"
            } else {
                formatBytes(value).replacing(" ", with: "")
            }
        } else {
            "-"
        }
    }
    
    private var gaugeValue: Double {
        param == "RAM" || param == "SSD" ? value / pow(1024, 2) : value
    }
    
    private let gradient = Gradient(colors: [.mint, .orange, .red])
    private let redGradient = Gradient(colors: [.red])
    
    var body: some View {
        Group {
            if gaugeValue <= limit {
                Gauge(value: gaugeValue, in: 0...limit) {
                    Text(param)
                } currentValueLabel: {
                    Text(valueLabel)
                        .redacted(isRedacted)
                }
                .tint(value == 0 ? .none : gradient)
            } else {
                Gauge(value: limit, in: 0...limit) {
                    Text(param)
                } currentValueLabel: {
                    Text(valueLabel)
                        .foregroundStyle(.red)
                        .redacted(isRedacted)
                }
                .tint(redGradient)
            }
        }
        .gaugeStyle(.accessoryCircular)
        .padding(2)
    }
}

#Preview {
    VStack {
        CircularGauge(
            param: "CPU",
            value: 5,
            limit: 10,
            isRedacted: false
        )
        
        CircularGauge(
            param: "CPU",
            value: 15,
            limit: 10,
            isRedacted: false
        )
    }
#if os(visionOS)
    .padding()
    .glassBackgroundEffect()
#endif
}
