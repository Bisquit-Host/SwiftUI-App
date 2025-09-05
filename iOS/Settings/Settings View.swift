import ScrechKit

struct SettingsView: View {
#warning("Move to the biometry settings")
    @State private var vm = BiometryVM()
    
    @State private var sheetAccount = false
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            AccountSettings()
                .foregroundStyle(.foreground)
            
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
