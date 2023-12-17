import ScrechKit

struct BrowserTopbar: View {
    @Environment(BrowserVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    private let categories = [
        "Minecraft",
        "Web",
        "Bot"
    ]
    
    var body: some View {
        @Bindable var binding = vm
        
        Picker("Category", selection: $binding.filterRule) {
            //        Picker("Category", selection: $settings.browserCategory) {
            ForEach(categories, id: \.self) { category in
                Text(category)
                    .tag(category)
            }
        }
        .padding(.horizontal)
        .pickerStyle(.segmented)
    }
}

#Preview {
    BrowserTopbar()
        .environment(BrowserVM())
        .environmentObject(SettingsStorage())
}
