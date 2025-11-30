import SwiftUI

struct MetricGaugeCompact: View {
    let icon: String
    let value: Double
    let color: Color
    
    // Percent for label; clamp negatives/NaN to 0
    private var percentValue: Double {
        guard value.isFinite else { return 0 }
        return max(value * 100, 0)
    }
    
    // ProgressView in 0...100, zeroed when under 1%
    private var progressValue: Double {
        let percent = percentValue
        return percent < 1 ? 0 : percent
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .fontSize(12)
                .fontWeight(.medium)
                .foregroundColor(color)
                .frame(width: 14)
            
            ProgressView(value: progressValue, total: 100)
                .progressViewStyle(.linear)
                .tint(color)
                .frame(height: 6)
            
            Text("\(Int(percentValue))%")
                .monospacedDigit()
                .secondary()
                .fontSize(10)
                .fontWeight(.medium)
                .frame(width: 28, alignment: .trailing)
        }
    }
}
