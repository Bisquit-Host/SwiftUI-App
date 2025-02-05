import ScrechKit

struct BrowserTopbar: View {
    @Environment(BrowserVM.self) private var vm
    
    private let categories = [
        "Minecraft",
        "Web",
        "Bot"
    ]
    
    var body: some View {
        @Bindable var vm = vm
        
        Picker("Category", selection: $vm.filterRule) {
            //        Picker("Category", selection: $store.browserCategory) {
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
}
