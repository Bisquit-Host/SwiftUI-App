import ScrechKit
import Kingfisher

struct Guide: View {
    private let steps = [
        GuideStep("Guide.Step1", id: 1, url: getImageUrl("step1")),
        GuideStep("Guide.Step2", id: 2, url: getImageUrl("step2")),
        GuideStep("Guide.Step3", id: 3, url: getImageUrl("bisquit"))
    ]
    
    private let width = UIScreen.main.bounds.width
    
    var body: some View {
        TabView {
            ForEach(steps, id: \.id) { step in
                let text = step.text
                let id = step.id
                let url = step.url
                
                HStack {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width / 2)
                    
                    VStack {
                        Text(text)
                        
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
                    Text("Step \(id)")
                }
            }
        }
    }
}

#Preview {
    Guide()
}
