import ScrechKit

struct PlanListTopbar: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Picker("Category", selection: $store.selectedPlanCategory) {
            ForEach(PlanType.allCases) {
                Text($0.localized)
                    .tag($0)
            }
        }
        .padding(.horizontal)
        .pickerStyle(.segmented)
    }
}

#Preview {
    PlanListTopbar()
        .environmentObject(ValueStore())
}
