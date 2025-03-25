import ScrechKit

struct SettingsView: View {
    //    private var vm = SettingsVM()
    //    @EnvironmentObject private var store: ValueStore
    
    //    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        List {
            
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .sheet {
                SettingsView()
            }
            .environmentObject(ValueStore())
    }
}
