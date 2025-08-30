import SwiftUI

struct Guide: View {
    private let steps = [
        GuideStep("Open the link, log in, and navigate to account settings", id: 1, image: .step0),
        GuideStep("Scroll down to the \"API/SSH\" section, enter a name for the API key, and tap \"Create\"", id: 2, image: .step1),
        GuideStep("Tap \"Authorize App\" or copy the API key", id: 3, image: .step2)
    ]
    
    var body: some View {
        GeometryReader { geo in
            TabView {
                ForEach(steps) {
                    GuideStepCard($0, geo: geo)
                }
            }
        }
    }
}

#Preview {
    Guide()
        .padding()
        .glassBackgroundEffect()
}
