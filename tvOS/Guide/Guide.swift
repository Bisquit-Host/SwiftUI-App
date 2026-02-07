import SwiftUI

struct Guide: View {
    private let steps = [
        GuideStep("Open the link, log in, and navigate to account settings", id: 1, image: .step0),
        GuideStep("Scroll down to the \"API/SSH\" section, enter a name for the API key, and tap \"Create\"", id: 2, image: .step1),
        GuideStep("Tap \"Authorize App\" or copy the API key", id: 3, image: .step2)
    ]
    
    var body: some View {
        TabView {
            Tab("Step 1", systemImage: "1.circle") {
                let step = steps[0]
                
                HStack {
                    Image(step.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text(step.text)
                        
                        Text(Endpoint.bisquitPter)
                            .title2()
                            .padding(20)
                            .background(.blue, in: .capsule)
                    }
                    .title(.semibold)
                    .frame(maxWidth: .infinity)
                }
            }
            
            Tab("Step 2", systemImage: "2.circle") {
                let step = steps[1]
                
                HStack {
                    Image(step.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text(step.text)
                    }
                    .title(.semibold)
                    .frame(maxWidth: .infinity)
                }
            }
            
            Tab("Step 3", systemImage: "3.circle") {
                let step = steps[2]
                
                HStack {
                    Image(step.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text(step.text)
                    }
                    .title(.semibold)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

#Preview {
    Guide()
        .darkSchemePreferred()
}
