import SwiftUI

struct Guide: View {
    private let steps = [
        GuideStep("Follow the link, log in to your account and go to profile settings", id: 1, url: getImageUrl("step1")),
        GuideStep("Open the API section, enter any name for the API-Key and click the Create button. Then save your key to the clipboard", id: 2, url: getImageUrl("step2")),
        GuideStep("To avoid input errors, paste the API-key from the clipboard", id: 3, url: getImageUrl("bisquit"))
    ]
    
    var body: some View {
        GeometryReader { geo in
            TabView {
                ForEach(steps) { step in
                    GuideStepCard(step, geo: geo)
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
