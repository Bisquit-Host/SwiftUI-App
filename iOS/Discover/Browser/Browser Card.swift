import ScrechKit
import Kingfisher

func customRound(_ value: Double) -> String {
    let roundedValue = round(value)
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = (roundedValue == value) ? 0 : 1
    
    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

struct BrowserCard: View {
    @Environment(\.colorScheme) private var scheme
    
    private let plan: Plan
    
    init(_ plan: Plan) {
        self.plan = plan
    }
    
    @State private var showSafari = false
    
    private var url: String {
        var path = ""
        
        switch plan.type {
        case "Bot":
            path = "bothost"
            
        case "Web":
            path = "web"
            
        default:
            path = "minecraft"
        }
        
        return "https://my.bisquit.host/store/\(path)/"
    }
    
    private var ram: Double {
        plan.ram * pow(10, 9)
    }
    
    private var disk: Double {
        plan.disk * pow(10, 9)
    }
    
//    private var price: Double {
//        switch SettingsStorage().preferredCurrency {
//        case "€":
//            plan.price_euro
//            
//        case "$":
//            plan.price_usd
//            
//        default:
//            plan.price_rub
//        }
//    }
    
    var body: some View {
        ZStack {
            KFImage(getImageUrl("plans/\(plan.name)"))
                .placeholder {
                    Text("Soon there will be an art here as well")
                        .padding(.horizontal)
                        .footnote()
                        .monospaced()
                }
                .resizable()
                .brightness(scheme == .dark ? -0.1 : 0)
            
            KFImage(getImageUrl("plans/\(plan.name)"))
                .resizable()
                .mask(alignment: .topLeading) {
                    Text(plan.name)
                        .title()
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background()
                        .cornerRadius(16)
                }
                .blur(radius: 4)
                .brightness(scheme == .dark ? -0.1 : 0)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(plan.name)
                        .title(.semibold)
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 5)
                    
                    Spacer()
                    
                    HStack {
                        if plan.type != "Web" {
                            BrowserSpec("\(customRound(plan.cpu))x", icon: "cpu")
                            BrowserSpec(formatBytes(ram, countStyle: .decimal), icon: "memorychip")
                        } else {
                            BrowserSpec("\(customRound(plan.cpu))x", icon: "macwindow.on.rectangle")
                            BrowserSpec("\(Int(ram / 1_000_000_000))x", icon: "server.rack")
                        }
                        
                        BrowserSpec(formatBytes(disk, countStyle: .decimal), icon: "internaldrive")
//                        
//                        Spacer()
//                        
//                        Text(customRound(price) + SettingsStorage().preferredCurrency)
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
        .onTapGesture {
            showSafari = true
        }
#if os(tvOS)
        .frame(height: 500)
#else
        .safariCover($showSafari, url: url + plan.url)
        .frame(height: 160)
#endif
        .cornerRadius(20)
        .padding(5)
    }
}

#Preview {
    BrowserCard(
        Plan(
            "",
            type: "Minecraft",
            url: "bee",
            cpu: 4,
            ram: 4,
            disk: 64,
            price_euro: 16,
            price_rub: 1600,
            price_usd: 16
        )
    )
}
