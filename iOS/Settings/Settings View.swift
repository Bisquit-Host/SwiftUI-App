import ScrechKit

struct SettingsView: View {
    @State private var vm = SettingsVM()
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            DesignSettings()
            
            CacheSettings()
            
            OtherSettings()
                .environment(vm)
            
            AppIconSettings()
            
            DevSettings()
        }
        .navigationTitle("Settings")
        .scrollIndicators(.hidden)
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
    NavigationStack {
        Text("Preview")
            .sheet {
                SettingsView()
            }
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
