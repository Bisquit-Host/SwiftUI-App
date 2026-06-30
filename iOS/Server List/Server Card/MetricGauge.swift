import SwiftUI

struct MetricGauge: View {
    let title: LocalizedStringKey
    let value: Double
    let color: Color
    let icon: String
    
    private let spacing = System.isWatch ? 4.0 : 12
    private let progressScale = System.isWatch ? 0.75 : 1.5
    
    /// Convert to percent for display/ProgressView; show 0 when < 1%
    private var percentValue: Double {
        guard value.isFinite else { return 0 }
        return max(value * 100, 0)
    }
    
    private var progressValue: Double {
        let percent = percentValue
        guard percent >= 1 else { return 0 }
        return min(percent, 100)
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: icon)
                .fontSize(16)
                .fontWeight(.medium)
                .foregroundStyle(color)
                .frame(width: 20)
            
            Text(title)
                .fontSize(14)
                .fontWeight(.medium)
                .frame(width: 40, alignment: .leading)
            
            ProgressView(value: progressValue, total: 100)
                .progressViewStyle(.linear)
                .tint(color)
                .scaleEffect(y: progressScale)
            
            Group {
                if percentValue.isFinite {
                    Text("\(Int(percentValue))%")
                } else {
                    Text("∞")
                }
            }
            .monospacedDigit()
            .secondary()
            .fontSize(12)
            .fontWeight(.medium)
            .frame(width: 35, alignment: .trailing)
        }
    }
}
