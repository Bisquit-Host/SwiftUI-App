import ScrechKit

struct DiskGauge: View {
    private var value, limit: Double
    //    private let color: Color
    private var isRedacted: Bool
    
    init(_ value: Double = 0,
         limit: Double = 0,
         //        color: Color = .secondary,
         isRedacted: Bool = false
    ) {
        self.value = value
        self.limit = limit
        //        self.color = color
        self.isRedacted = isRedacted
    }
    
    var body: some View {
        let valuePercentage = (value / pow(1024, 2) / limit) * 100
        let currentValue = formatBytes(value) + " / " + String(format: "%.0f", valuePercentage) + "%"
        let maximumValue = String(Int(limit / 1024))
        
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
    }
}

#Preview {
    DiskGauge()
}
