import ScrechKit
import Kingfisher

struct BrowserCardWeb: View {
    @Environment(\.colorScheme) private var scheme
    
    private let plan: WebPlan
    
    init(_ plan: WebPlan) {
        self.plan = plan
    }
    
    private var url: String {
        "https://my.bisquit.host/store/\(plan.name)"
    }
    
    private var price: Double {
        switch ValueStore().preferredCurrency {
        case "€":
            plan.priceEur
            
        case "$":
            plan.priceUsd
            
        default:
            plan.priceRub
        }
    }
    
    var body: some View {
        Button {
            
        } label: {
            ZStack {
                KFImage(getImageUrl("plans/" + plan.name))
                    .placeholder {
                        Text("Soon there will be an art here as well")
                            .padding(.horizontal)
                            .footnote()
                            .monospaced()
                    }
                    .resizable()
                    .brightness(scheme == .dark ? -0.1 : 0)
                
                KFImage(getImageUrl("plans/" + plan.name))
                    .resizable()
                    .mask(alignment: .topLeading) {
                        Text(plan.name)
                            .title()
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background()
                            .clipShape(.rect(cornerRadius: 16))
                    }
                    .blur(radius: 4)
                    .brightness(scheme == .dark ? -0.1 : 0)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(plan.displayname)
                            .title(.semibold)
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 5)
                        
                        Spacer()
                        
                        HStack {
                            BrowserSpec("\(plan.disk) GB", icon: "internaldrive")
                            
                            BrowserSpec("\(plan.mysql)", icon: "server.rack")
                            
                            //                        Spacer()
                            //
                            //                        Text(customRound(price) + ValueStore().preferredCurrency)
                            //                            .subheadline(.bold)
                            //                            .padding(.vertical, 4)
                            //                            .padding(.horizontal, 10)
                            //                            .foregroundStyle(.white)
                            //     .background(.blue, in: .capsule)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
#if os(tvOS)
            .frame(height: 500)
#else
            .frame(height: 160)
#endif
            .clipShape(.rect(cornerRadius: 20))
            .padding(5)
        }
        .buttonStyle(.plain)
    }
}

//#Preview {
//    BrowserCardWeb()
//}
