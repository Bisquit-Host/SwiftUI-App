import ScrechKit

struct SettingsView: View {
    @State private var vm = SettingsVM()
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            DesignSettings()
            
            CacheSettings()
            
            OtherSettings()
                .environment(vm)
            
            IconSettings()
            
            DevSettings()
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .transparentList()
        .dismissWithGamepad()
        .sheet($vm.sheetBio) {
            BiometryUsageView()
        }
        .task {
            vm.defineBiometryType()
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .sheet {
                SettingsView()
            }
    }
    .environmentObject(ValueStore())
}
