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
        .task {
            vm.defineBiometryType()
        }
        .sheet($vm.sheetBio) {
            BiometryUsageView()
        }
    }
}

#Preview {
    Text("Preview")
        .sheet {
            NavigationStack {
                SettingsView()
            }
        }
        .environmentObject(ValueStore())
}
