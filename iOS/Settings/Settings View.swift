import ScrechKit

struct SettingsView: View {
    @State private var vm = SettingsVM()
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            DesignSettings()
            
            IconSettings()
            
            CacheSettings()
            
            OtherSettings()
                .environment(vm)
            
            WideListButton("Need help?", color: .blue.gradient) {
                vm.sheetSupport = true
            }
            .semibold()
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .padding(.vertical, 4)
            
            DevSettings()
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .scrollContentBackground(store.transparentSheet ? .hidden : .visible)
        .presentationBackground(store.transparentSheet ? .ultraThinMaterial : .regular)
        .sheet($vm.sheetSupport) {
            Support()
        }
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
