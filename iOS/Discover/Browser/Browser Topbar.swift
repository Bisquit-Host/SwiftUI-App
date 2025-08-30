import ScrechKit

struct BrowserTopbar: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        Picker("Category", selection: $vm.selectedCategory) {
            ForEach(Plan.allCases) {
                Text($0.localized)
                    .tag($0)
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
