import ScrechKit

struct LinearGauge: View {
    private let value, limit: Double
    
    init(value: Double,
         limit: Double
    ) {
        self.value = value
        self.limit = limit
    }
    
    private let gradient = Gradient(colors: [.mint, .orange, .red])
    private let red_gradient = Gradient(colors: [.red])
    private var valueGigabytes: Double {
        value / pow(1024, 2)
    }
    private var limitBytes: Double {
        limit * pow(1024, 2)
    }
    
    var body: some View {
        Group {
            if valueGigabytes <= limit {
                Gauge(value: valueGigabytes, in: 0...limit) {
                    Text("SSD")
                } currentValueLabel: {
                    Text(formatBytes(value) + " / " + formatBytes(limitBytes, countStyle: .memory))
                }
                .tint(value == 0 ? .none : gradient)
            } else {
                
                Gauge(value: limit, in: 0...limit) {
                    Text("SSD")
                } currentValueLabel: {
                    Text(formatBytes(value) + " / " + formatBytes(limitBytes, countStyle: .memory))
                        .foregroundStyle(.red)
                }
                .tint(red_gradient)
            }
        }
        .frame(width: 160)
        .padding(2)
    }
}

#Preview {
    VStack {
        LinearGauge(value: 5, limit: 10)
        LinearGauge(value: 15, limit: 10)
    }
    .padding()
    .glassBackgroundEffect()
}
