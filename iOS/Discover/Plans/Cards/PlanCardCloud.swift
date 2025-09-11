import ScrechKit

struct PlanCardCloud: View {
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
            HStack {
                VStack(alignment: .leading) {
                    Text(plan.name)
                        .title(.semibold)
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 5)
                    
                    Spacer()
                    
                    HStack {
                        if let ram = plan.memoryGB {
                            PlanSpec("RAM", icon: "memorychip", value: "\(customRound(ram)) GB")
                        }
                        
                        if let cpu = plan.cpu {
                            PlanSpec("CPU", icon: "cpu", value: "\(customRound(cpu))x")
                        }
                        
                        PlanSpec("Storage", icon: "internaldrive", value: "\(plan.diskGB) GB")
                        
                        if let network = plan.network {
                            PlanSpec("Network", icon: "globe", value: "\(network) Mbit/s")
                        }
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
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.indigo.gradient.opacity(0.3))
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
//    PlanCardCloud()
//        .environmentObject(ValueStore())
//}
