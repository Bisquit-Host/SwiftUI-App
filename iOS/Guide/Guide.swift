import ScrechKit
import PteroNet

struct Guide: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private let steps: [LocalizedStringKey] = [
        "Open the link, log in, and navigate to account settings",
        "Scroll down to the API/SSH section, enter a name for the API key, and tap Create",
        "Tap Authorize App or copy the API key"
    ]
    
    private let images = [
        "step0",
        "step1",
        "step2"
    ]
    
    private var gradient: AngularGradient {
        AngularGradient(
            colors: colors,
            center: .init(x: 0.5, y: 1.0),
            angle: .degrees(180 * Double(step) / Double(steps.count - 1)))
    }
    
    private var colors: [Color] {
        switch colorScheme {
        case .dark:
            [.blue.opacity(0.5), .mint.opacity(0.5), .gray.opacity(0.5)]
            
        default:
            [.blue, .mint, .gray]
        }
    }
    
    @State private var step = 0
    @State private var apiKey = ""
    @ScaledMetric private var fontSize = 18
    
    var body: some View {
        VStack {
            Text("API-key Creation")
                .headline()
                .padding(.top)
            
            Text("Step \(step + 1)")
                .subheadline()
            
            Spacer()
            
            Image(images[step])
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .padding()
            
            Text(steps[step])
                .semibold()
                .serif()
                .fontSize(fontSize)
                .padding()
                .tightening(true)
                .lineLimit(1...5)
            
            if step == 0, let url = URL(string: "https://mgr.bisquit.host") {
                Link(destination: url) {
                    Image(systemName: "link")
                        .title2(.semibold)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.blue, in: .capsule)
                }
            }
            
            Spacer()
            
            HStack {
                MenuButton("Previous", icon: "chevron.backward") {
                    withAnimation(.easeOut(duration: 0.6)) {
                        step -= 1
                    }
                }
                .disabled(step - 1 < 0)
                
                Spacer()
                
                MenuButton("Next", icon: "chevron.forward") {
                    withAnimation(.easeOut(duration: 0.6)) {
                        step += 1
                    }
                }
                .disabled(step + 1 >= steps.count)
            }
            .buttonStyle(CarouselButtonStyle())
            .padding(20)
        }
        .background(gradient)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    Guide()
}
