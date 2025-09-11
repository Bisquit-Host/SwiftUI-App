import ScrechKit

struct PlanCardBot: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var appearance
    
    private let plan: UniversalPlan
    
    init(_ plan: UniversalPlan) {
        self.plan = plan
    }
    
    private var url: URL? {
        URL(string: "https://my.bisquit.host/store/" + plan.name)
    }
    
    var body: some View {
        Button {
            if let url {
                openURL(url)
            }
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    PlanCardName(plan.name)
                    
                    Spacer()
#if DEBUG
                    PlanCardPrice(plan.price)
#endif
                }
                
                HStack {
                    if let ram = plan.memoryGB {
                        PlanSpec("RAM", icon: "memorychip", value: "\(customRound(ram)) GB")
                    }
                    
                    if let cpu = plan.cpu {
                        PlanSpec("CPU", icon: "cpu", value: "\(customRound(cpu))x")
                    }
                    
                    PlanSpec("Storage", icon: "internaldrive", value: "\(plan.diskGB) GB")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.indigo.gradient.opacity(0.3))
            }
            .clipShape(.rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

//#Preview {
//    PlanCardBot()
//        .environmentObject(ValueStore())
//}
