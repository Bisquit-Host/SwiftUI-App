import ScrechKit

struct PlanViewTopbar: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Picker("Category", selection: $store.selectedPlanCategory) {
            ForEach(PlanType.allCases) {
                Text($0.localized)
                    .tag($0)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    PlanViewTopbar()
        .environmentObject(ValueStore())
}
