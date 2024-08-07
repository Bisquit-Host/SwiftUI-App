import ScrechKit

struct ServerCardNaStatus: View {
    private let name: String
    private let color: Color
    
    init(_ name: String, color: Color) {
        self.name = name
        self.color = color
    }
    
    @State private var showPulseCircle = false
    
    var body: some View {
        HStack {
            Text(name)
                .headline()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)
//            
//            if showPulseCircle {
//                PulseCircle(color)
//            }
        }
        .onAppear {
            delay(0.8) {
                withAnimation {
                    showPulseCircle = true
                }
            }
        }
        .onDisappear {
            showPulseCircle = false
        }
    }
}
