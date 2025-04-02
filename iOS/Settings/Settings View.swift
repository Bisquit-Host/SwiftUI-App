import ScrechKit

struct SettingsView: View {
    @State private var vm = SettingsVM()
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            DesignSettings()
            
            IconSettings()
            
            CacheSettings()
            
            OtherSettings()
                .environment(vm)
                        
            DevSettings()
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .transparentList()
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
