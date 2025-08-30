import ScrechKit

struct GaugeDisk: View {
    private var value: Double
    private var limit: Double
    
    init(_ value: Double = 0, limit: Double = 0) {
        self.value = value
        self.limit = limit
    }
    
    var body: some View {
        let currentValue = formatBytes(value)
        let maximumValue = limit == 0 ? "∞" : String(Int(limit / 1024))
        
        if limit != 0 {
            Gauge(value: value / pow(1024, 2), in: 0...limit) {
                HStack(spacing: 0) {
                    let separator = Text("/")
                        .foregroundStyle(.secondary)
                    
                    Text("\(currentValue) \(separator) \(maximumValue) GB")
                }
                .footnote(.semibold, design: .rounded)
                .offset(y: 5)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 5)
            // .gaugeStyle(.accessoryLinearCapacity) // CRASH
            .foregroundStyle(.foreground)
            .tint(.accent)
        } else {
            Text(formatBytes(value) + " / " + maximumValue)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview {
    GaugeDisk(1024, limit: 2048 * 1024)
}
