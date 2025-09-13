import SwiftUI

struct PerformanceCard: View {
    var body: some View {
        Card("Performance") {
            Text("86%")
                .largeTitle(.bold)
        } content: {
            VStack(alignment: .leading, spacing: 16) {
                Text("+15% vs last Week")
                    .secondary()
                
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(Bar.sample) { bar in
                        VStack {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: 30, height: CGFloat(bar.value))
                                .overlay(alignment: .bottom) {
                                    Text("\(bar.value)%")
                                        .caption2()
                                        .padding(.bottom, 4)
                                }
                            
                            Text(bar.label)
                                .caption()
                                .secondary()
                        }
                    }
                }
            }
        }
        .frame(width: 360)
    }
}

#Preview {
    PerformanceCard()
}
