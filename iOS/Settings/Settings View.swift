import ScrechKit

struct SettingsView: View {
    @State private var sheetAccount = false
    
    var body: some View {
        List {
            AccountSettings()
                .foregroundStyle(.foreground)
            
            DesignSettings()
            
            CacheSettings()
            
            OtherSettings()
            
            AppIconSettings()
            
            DevSettings()
        }
        .navigationTitle("Settings")
        .scrollIndicators(.hidden)
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
        SettingsView()
    }
    .environmentObject(ValueStore())
}
