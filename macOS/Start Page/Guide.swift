import SwiftUI
import PteroNet

struct Guide: View {
    @Environment(\.colorScheme) private var appearance
    @Environment(\.dismiss) private var dismiss
    
    private let steps: [LocalizedStringKey] = [
        "Open the link, log in, and navigate to account settings",
        "Scroll down to the \"API/SSH\" section, enter a name for the API key, and tap \"Create\"",
        "Tap \"Authorize App\" or copy the API key"
    ]
    
    private let images: [ImageResource] = [
        .step0, .step1, .step2
    ]
    
    private var colors: [Color] {
        switch appearance {
        case .dark:
            [.blue.opacity(0.5), .mint.opacity(0.5), .gray.opacity(0.5)]
            
        default:
            [.blue, .mint, .gray]
        }
    }
    
    private var gradient: AngularGradient {
        .init(
            colors: colors,
            center: .init(x: 0.5, y: 1.0),
            angle: .degrees(180 * Double(step) / Double(steps.count - 1))
        )
    }
    
    @State private var step = 0
    @ScaledMetric private var fontSize = 18
    
    var body: some View {
        VStack {
            Text("API-key Creation")
                .headline()
                .padding(.top)
            
            Text(.step(step + 1))
                .subheadline()
            
            Spacer()
            
            Image(images[step])
                .resizable()
                .scaledToFit()
                .clipShape(.rect(cornerRadius: 10))
                .padding()
            
            Text(steps[step])
                .semibold()
                .serif()
                .fontSize(fontSize)
                .padding()
                .tightening(true)
                .lineLimit(1...5)
            
            if step == 0, let url = URL(string: Endpoint.bisquitPter) {
                Link(destination: url) {
                    Image(systemName: "link")
                        .title2(.semibold)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.blue, in: .capsule)
                }
            }
            
            if step == 2 {
                Button {
                    dismiss()
                } label: {
                    Text("Dismiss")
                        .title2(.semibold)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.blue, in: .capsule)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            GuideControls($step, stepCount: steps.count)
        }
        .background(gradient)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    Guide()
        .darkSchemePreferred()
}
