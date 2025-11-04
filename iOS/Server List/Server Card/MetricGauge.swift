import SwiftUI

struct MetricGauge: View {
    let title: String
    let value: Double
    let color: Color
    let icon: String
    
    private let spacing = System.isWatch ? 4.0 : 12
    
    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: icon)
                .fontSize(16)
                .fontWeight(.medium)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .fontSize(14)
                .fontWeight(.medium)
                .frame(width: 40, alignment: .leading)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.ultraThinMaterial)
                        .frame(height: 8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                        }
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.8),
                                    color
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * value, height: 8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white.opacity(0.3), lineWidth: 0.5)
                        }
                }
            }
            .frame(height: 8)
            
            Group {
                if value.isFinite {
                    Text("\(Int(value * 100))%")
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
