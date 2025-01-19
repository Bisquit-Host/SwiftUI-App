import ScrechKit
//import Kingfisher

struct Guide: View {
    private let steps = [
        GuideStep("Guide.Step1", id: 1, url: getImageUrl("step1")),
        GuideStep("Guide.Step2", id: 2, url: getImageUrl("step2")),
        GuideStep("Guide.Step3", id: 3, url: getImageUrl("bisquit"))
    ]
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            
            TabView {
                ForEach(steps, id: \.id) { step in
                    let text = step.text
                    let id = step.id
                    let url = step.url
                    
                    HStack {
                        AsyncImage(url: url) { image in
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
                            Text(text)
                                .title()
                                .padding(20)
                                .multilineTextAlignment(.center)
                            
                            if id == 1 {
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
                        Label("Step", systemImage: "\(id).circle")
                    }
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
