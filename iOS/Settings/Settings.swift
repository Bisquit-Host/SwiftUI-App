import ScrechKit

struct Settings: View {
    private var vm = SettingsVM()
    @EnvironmentObject private var settings: SettingsStorage
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        @Bindable var binding = vm
        
        List {
            AccountSettings()
            
            DesignSettings()
            
            IconSettings()
            
            CacheSettings()
            
            OtherSettings()
                .environment(vm)
            
            Group {
                WideListButton("Change language", color: .orange.gradient) {
                    openSettings()
                }
                
                WideListButton("Need help?", color: .blue.gradient) {
                    vm.sheetSupport = true
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .semibold()
            .padding(.vertical, 4)
            
            DevSettings()
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .scrollContentBackground(settings.transparentSheet ? .hidden : .visible)
        .presentationBackground(settings.transparentSheet ? .ultraThinMaterial : .regular)
        .sheet($binding.sheetSupport) {
            Support()
        }
        .sheet($binding.sheetBio) {
            BiometryUsageView()
        }
        .task {
            vm.defineBiometryType()
        }
        .onChange(of: settings.currentIcon) { _, newValue in
            UIApplication.shared.setAlternateIconName(newValue)
        }
    }
}

#Preview {
    NavigationView {
        Settings()
            .sheet(.constant(true)) {
                Settings()
            }
            .environmentObject(SettingsStorage())
    }
}
