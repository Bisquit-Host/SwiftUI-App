import ScrechKit

#warning("Finish")
struct SettingsView: View {
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
                SettingsView()
            }
    }
    .environmentObject(ValueStore())
}
