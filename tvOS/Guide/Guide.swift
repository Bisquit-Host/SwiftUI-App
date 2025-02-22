import ScrechKit
import Kingfisher

struct Guide: View {
    private let width = UIScreen.main.bounds.width
    private let steps = [
        GuideStep("Follow the link, log in to your account and go to profile settings", id: 1, url: getImageUrl("step1")),
        GuideStep("Open the API section, enter any name for the API-Key and click the Create button. Then save your key to the clipboard", id: 2, url: getImageUrl("step2")),
        GuideStep("To avoid input errors, paste the API-key from the clipboard", id: 3, url: getImageUrl("bisquit"))
    ]
    
    var body: some View {
        TabView {
            ForEach(steps) { step in
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
