import SwiftUI

struct CompactMetricRow: View {
    let icon: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .fontSize(12)
                .fontWeight(.medium)
                .foregroundColor(color)
                .frame(width: 14)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.ultraThinMaterial)
                        .frame(height: 6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                        }
                    
                    RoundedRectangle(cornerRadius: 4)
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
                        .frame(width: geo.size.width * value, height: 6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(.white.opacity(0.3), lineWidth: 0.5)
                        }
                }
            }
            .frame(height: 6)
            
            Text("\(Int(value * 100))%")
                .monospacedDigit()
                .secondary()
                .fontSize(10)
                .fontWeight(.medium)
                .frame(width: 28, alignment: .trailing)
        }
    }
}
