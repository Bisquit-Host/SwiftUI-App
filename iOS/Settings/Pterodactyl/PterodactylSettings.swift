import ScrechKit

struct PterodactylSettings: View {
    @State private var sheetAccount = false
    
    var body: some View {
        ScrollView {
            AccountSettings()
            CustomizationSettings()
            OtherSettings()
        }
        .scrollIndicators(.never)
        .scenePadding(.horizontal)
        .sheet($sheetAccount) {
            AccountParent()
        }
        .toolbar {
            Button("Account", systemImage: "person.crop.circle") {
                sheetAccount = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        PterodactylSettings()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
