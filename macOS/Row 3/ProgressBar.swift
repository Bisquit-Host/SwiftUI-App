import SwiftUI

struct ProgressBar: View {
    var progress: Double
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.white.opacity(0.08))
                .frame(height: 8)
            
            Capsule()
                .frame(width: nil, height: 8)
                .overlay {
                    GeometryReader { geo in
                        Capsule()
                            .fill(.white.opacity(0.2))
                            .frame(width: geo.size.width * progress)
                    }
                }
                .opacity(0)
        }
        .overlay {
            GeometryReader { geo in
                Capsule()
                    .fill(.blue)
                    .frame(width: geo.size.width * progress, height: 8)
            }
        }
    }
}
