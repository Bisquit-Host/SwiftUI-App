import ScrechKit

#warning("Finish")
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
