import ScrechKit
import Kingfisher

struct PlanCard: View {
    @Environment(\.colorScheme) private var appearance
    
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
            plan.priceEur
            
        default:
            plan.priceRub
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
                            .footnote(design: .monospaced)
                    }
                    .resizable()
                    .brightness(appearance == .dark ? -0.1 : 0)
                
                KFImage(getImageUrl("plans/\(plan.name)"))
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
                    .brightness(appearance == .dark ? -0.1 : 0)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(plan.displayname)
                            .title(.semibold)
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 5)
                        
                        Spacer()
                        
                        HStack {
                            PlanSpec("\(plan.cpu)x", icon: "macwindow.on.rectangle")
                            
                            PlanSpec("\(Int(plan.ram / 1_000_000_000))x", icon: "server.rack")
                            
                            PlanSpec(formatBytes(plan.disk, countStyle: .decimal), icon: "internaldrive")
                            
                            Spacer()
                            
                            Text(customRound(price) + ValueStore().preferredCurrency)
                                .subheadline(.bold)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .foregroundStyle(.white)
                                .background(.blue, in: .capsule)
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
    
    private func customRound(_ value: Double) -> String {
        let roundedValue = round(value)
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = (roundedValue == value) ? 0 : 1
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

#Preview {
    PlanCard(MinecraftPlan(
        id: 16,
        ram: 16,
        disk: 16,
        mysql: 16,
        name: "preview",
        location: "Netherlands",
        displayname: "Preview",
        cpuModel: "M4 Ultra",
        cpu: "4",
        priceRub: 2000,
        priceEur: 20.4
    ))
}
