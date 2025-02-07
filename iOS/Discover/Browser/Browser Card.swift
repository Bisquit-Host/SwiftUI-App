import ScrechKit
import Kingfisher

//func customRound(_ value: Double) -> String {
//    let roundedValue = round(value)
//    let formatter = NumberFormatter()
//    formatter.minimumFractionDigits = 0
//    formatter.maximumFractionDigits = (roundedValue == value) ? 0 : 1
//
//    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
//}

struct BrowserCard: View {
    @Environment(\.colorScheme) private var scheme
    
    private let plan: MinecraftPlan
    
    init(_ plan: MinecraftPlan) {
        self.plan = plan
    }
    
    private var url: String {
        "https://my.bisquit.host/store/\(plan.name)"
    }
    
    private var price: Double {
        switch ValueStore().preferredCurrency {
        case "€":
            plan.price_eur
            
        case "$":
            plan.price_usd
            
        default:
            plan.price_rub
        }
    }
    
    var body: some View {
        Button {
            
        } label: {
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
                        Text(plan.displayname)
                            .title(.semibold)
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 5)
                        
                        Spacer()
                        
                        HStack {
                            BrowserSpec("\(plan.cpu)x", icon: "macwindow.on.rectangle")
                            
                            BrowserSpec("\(Int(plan.ram / 1_000_000_000))x", icon: "server.rack")
                            
                            BrowserSpec(formatBytes(plan.disk, countStyle: .decimal), icon: "internaldrive")
                            
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
            .cornerRadius(20)
            .padding(5)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BrowserCard(MinecraftPlan(
        id: 16,
        ram: 16,
        disk: 16,
        mysql: 16,
        name: "preview",
        location: "Netherlands",
        displayname: "Preview",
        cpu_model: "M4 Ultra",
        cpu: "4",
        price_rub: 2000,
        price_eur: 20.4,
        price_usd: 20.5
    ))
}
