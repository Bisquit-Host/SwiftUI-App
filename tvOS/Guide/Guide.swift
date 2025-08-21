import SwiftUI

struct Guide: View {
    private let width = UIScreen.main.bounds.width
    
    private let steps = [
        GuideStep("Open the link, log in, and navigate to account settings", id: 1, image: .step0),
        GuideStep("Scroll down to the \"API/SSH\" section, enter a name for the API key, and tap \"Create\"", id: 2, image: .step1),
        GuideStep("Tap \"Authorize App\" or copy the API key", id: 3, image: .step2)
    ]
    
    var body: some View {
        TabView {
            ForEach(steps) { step in
                let id = step.id
                
                HStack {
                    Image(step.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width / 2)
                    
                    VStack {
                        Text(step.text)
                        
                        if id == 1 {
                            Text("https://mgr.bisquit.host")
                                .title2()
                                .padding(20)
                                .background(.blue, in: .capsule)
                        }
                    }
                    .title(.semibold)
                }
                .tabItem {
                    Text(.step(id))
                }
            }
        }
    }
}

#Preview {
    Guide()
}
