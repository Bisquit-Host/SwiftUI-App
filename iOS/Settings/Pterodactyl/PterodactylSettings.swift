import ScrechKit

struct PterodactylSettings: View {
    @State private var sheetAccount = false
    
    var body: some View {
        List {
            AccountSettings()
                .foregroundStyle(.foreground)
            
            CustomizationSettings()
            OtherSettings()
        }
        .navigationTitle("Settings")
        .scrollIndicators(.hidden)
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
