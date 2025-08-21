import ScrechKit

struct BrowserTopbar: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        Picker("Category", selection: $vm.selectedCategory) {
            ForEach(Plan.allCases) { category in
                Text(category.localized)
                    .tag(category)
            }
        }
        .padding(.horizontal)
        .pickerStyle(.segmented)
    }
}

#Preview {
    BrowserTopbar()
        .darkSchemePreferred()
        .environment(BrowserVM())
}
