import ScrechKit
import Kingfisher

struct PlanCardGame: View {
    @Environment(\.colorScheme) private var appearance
    @EnvironmentObject private var store: ValueStore
    
    private let plan: UniversalPlan
    
    init(_ plan: UniversalPlan) {
        self.plan = plan
    }
    
    private var url: String {
        "https://my.bisquit.host/store/" + plan.name
    }
    
    private var price: Double? {
        switch store.preferredCurrency {
        case "€":
            plan.price.first { $0.currency == "eur" }?.price
            
        default:
            plan.price.first { $0.currency == "rub" }?.price
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
                            .footnote(design: .monospaced)
                    }
                    .resizable()
                    .brightness(appearance == .dark ? -0.1 : 0)
                
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
                    .brightness(appearance == .dark ? -0.1 : 0)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(plan.name)
                            .title(.semibold)
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 5)
                        
                        Spacer()
                        
                        HStack {
                            if let cpu = plan.cpu?.description {
                                PlanSpec(cpu + "x", icon: "cpu")
                            }
                            
                            if let ram = plan.memoryGB {
                                PlanSpec("\(ram) GB", icon: "memorychip")
                            }
                            
                            PlanSpec("\(plan.diskGB) GB", icon: "internaldrive")
//#if DEBUG
//                            Spacer()
//                            
//                            Text(customRound(price) + store.preferredCurrency)
//                                .subheadline(.bold)
//                                .padding(.vertical, 4)
//                                .padding(.horizontal, 10)
//                                .foregroundStyle(.white)
//                                .background(.blue, in: .capsule)
//#endif
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
//    PlanCardGame()
//        .environmentObject(ValueStore())
//}
