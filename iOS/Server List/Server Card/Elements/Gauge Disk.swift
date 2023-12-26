import ScrechKit

struct DiskGauge: View {
    private var value, limit: Double
    private var isRedacted: Bool
    
    init(_ value: Double = 0,
         limit: Double = 0,
         isRedacted: Bool = false
    ) {
        self.value = value
        self.limit = limit
        self.isRedacted = isRedacted
    }
    
    var body: some View {
        let valuePercentage = (value / pow(1024, 2) / limit) * 100
        
        let currentValue = formatBytes(value) + " / " + String(format: "%.0f", valuePercentage) + "%"
        
        let maximumValue = limit == 0 ? "∞" : String(Int(limit / 1024))
        
        if limit != 0 {
            Gauge(value: value / pow(1024, 2), in: 0...limit) {
                Text("SSD")
                    .footnote()
                    .frame(maxWidth: .infinity, alignment: .center)
                
            } currentValueLabel: {
                Text(currentValue)
                    .frame(maxWidth: .infinity, alignment: .center)
                
            } minimumValueLabel: {
                Text("0")
                
            } maximumValueLabel: {
                Text(maximumValue)
            }
            .gaugeStyle(.accessoryLinearCapacity)
            .foregroundStyle(.foreground)
        } else {
            Text(formatBytes(value) + " / " + maximumValue)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview {
    DiskGauge()
}
