import SwiftUI

struct GuideStepCard: View {
    private let step: GuideStep
    private let geo: GeometryProxy
    
    init(_ step: GuideStep, geo: GeometryProxy) {
        self.step = step
        self.geo = geo
    }
    
    var body: some View {
        let size = geo.size
        
        HStack {
            AsyncImage(url: step.url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 16))
                    .padding()
            } placeholder: {
                ProgressView()
            }
            .frame(width: size.width / 2, height: size.height)
            
            VStack {
                Text(step.text)
                    .title()
                    .padding(20)
                    .multilineTextAlignment(.center)
                
                if step.id == 1 {
                    Text("https://mgr.bisquit.host")
                        .title2()
#if !os(visionOS)
                        .padding(20)
                        .background(.blue, in: .capsule)
#endif
                }
            }
            .semibold()
            .frame(width: size.width / 2)
        }
        .tabItem {
            Label("Step", systemImage: "\(step.id).circle")
        }
    }
}
