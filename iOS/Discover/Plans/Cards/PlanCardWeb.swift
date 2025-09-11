import ScrechKit

struct PlanCardWeb: View {
    @Environment(\.colorScheme) private var appearance
    
    private let plan: UniversalPlan
    
    init(_ plan: UniversalPlan) {
        self.plan = plan
    }
    
    private var url: String {
        "https://my.bisquit.host/store/" + plan.name
    }
    
    var body: some View {
        Button {
            
        } label: {
            VStack(alignment: .leading) {
                PlanCardName(plan.name)
                
                Spacer()
                
                HStack {
                    PlanSpec("Storage", icon: "internaldrive", value: "\(plan.diskGB) GB")
                    
                    if let databases = plan.databases {
                        PlanSpec("DB's", icon: "server.rack", value: "\(databases)x")
                    }
#if DEBUG
                    Spacer()
                    
                    PlanCardPrice(plan.price)
#endif
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
//    PlanCardWeb()
//        .environmentObject(ValueStore())
//}
