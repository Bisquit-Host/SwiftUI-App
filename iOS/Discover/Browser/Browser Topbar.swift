import ScrechKit

struct BrowserTopbar: View {
    @Environment(BrowserVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        Picker("Category", selection: $vm.filterRule) {
            ForEach(vm.categories, id: \.self) { category in
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
