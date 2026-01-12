import ScrechKit

#warning("Finish iMessage Settings")
struct PterodactylSettings: View {
    //    private var vm = SettingsVM()
    
    var body: some View {
        List {
            
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        Text("Preview")
            .sheet {
                PterodactylSettings()
            }
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
