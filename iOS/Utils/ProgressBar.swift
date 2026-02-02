import SwiftUI

struct ProgressBar: View {
    private let name: String
    private var progress: Double
    
    init(_ name: String, progress: Double) {
        self.name = name
        self.progress = progress
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(name.uppercased())
                .title3()
                .padding(.bottom, 10)
            
            ZStack {
                Group {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(min(progress, 1)))
                        .stroke(style: .init(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .rotate(270)
                        .animation(.linear, value: progress)
                }
                .foregroundStyle(.red)
                
                Text(progress, format: .percent.precision(.fractionLength(0)))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .monospacedDigit()
                    .title3(.bold)
            }
            .frame(150)
        }
    }
}
