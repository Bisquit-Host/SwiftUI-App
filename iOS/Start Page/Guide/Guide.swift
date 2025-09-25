import SwiftUI
import PteroNet

struct Guide: View {
    private let steps: [LocalizedStringKey] = [
        "Open the link, log in, and navigate to account settings",
        "Scroll down to the \"API/SSH\" section, enter a name for the API key, and tap \"Create\"",
        "Tap \"Authorize App\" or copy the API key"
    ]
    
    private let images: [ImageResource] = [
        .step0,
        .step1,
        .step2
    ]
    
    @State private var step = 0
    @State private var apiKey = ""
    @ScaledMetric private var fontSize = 18
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(images[step])
                .resizable()
                .scaledToFit()
                .clipShape(.rect(cornerRadius: 10))
                .padding()
            
            Text(steps[step])
                .semibold()
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
                Button("Previous", systemImage: "chevron.backward") {
                    withAnimation(.easeOut(duration: 0.6)) {
                        step -= 1
                    }
                }
                .disabled(step - 1 < 0)
                
                Spacer()
                
                Button("Next", systemImage: "chevron.forward") {
                    withAnimation(.easeOut(duration: 0.6)) {
                        step += 1
                    }
                }
                .disabled(step + 1 >= steps.count)
            }
            .buttonStyle(CarouselButtonStyle())
            .padding(20)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    Guide()
        .darkSchemePreferred()
}
