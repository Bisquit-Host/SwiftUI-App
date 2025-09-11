import ScrechKit

struct PlanCard: View {
    @Environment(\.openURL) private var openURL
    
    private let plan: UniversalPlan
    
    init(_ plan: UniversalPlan) {
        self.plan = plan
    }
    
    private var url: URL? {
        URL(string: "https://my.bisquit.host" + plan.whmcsLink)
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
                
                if plan.whmcsLink.contains("minecraft") {
                    PlanCardLabelGame(plan)
                } else if plan.whmcsLink.contains("vds") {
                    PlanCardLabelCloud(plan)
                } else if plan.whmcsLink.contains("bothost") {
                    PlanCardLabelBot(plan)
                } else if plan.whmcsLink.contains("web") {
                    PlanCardLabelWeb(plan)
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
        .disabled(!plan.enabled)
    }
}

//#Preview {
//    PlanCard()
//        .environmentObject(ValueStore())
//}
