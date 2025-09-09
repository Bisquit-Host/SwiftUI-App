import SwiftUI

struct GuideStepCard: View {
    private let step: GuideStep
    private let geo: GeometryProxy
    
    init(_ step: GuideStep, geo: GeometryProxy) {
        self.step = step
        self.geo = geo
    }
    
    private let link = "https://mgr.bisquit.host"
    
    var body: some View {
        let size = geo.size
        
        HStack {
            Image(step.image)
                .resizable()
                .scaledToFit()
                .clipShape(.rect(cornerRadius: 16))
                .padding()
                .frame(width: size.width / 2, height: size.height)
            
            VStack {
                Text(step.text)
                    .title()
                    .padding(20)
                    .multilineTextAlignment(.center)
                
                if step.id == 1, let url = URL(string: link) {
                    Link(destination: url) {
                        Image(systemName: "link")
                            .title2(.semibold)
                            .padding()
                            .foregroundStyle(.white)
                            .background(.blue, in: .capsule)
                    }
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
