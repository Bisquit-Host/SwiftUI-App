import ScrechKit

struct TextFile: View {
    @State private var vm: TextFileVM
    
    private let id, path, name: String
    
    init(_ id: String, path: String, name: String) {
        self.id = id
        self.path = path
        self.name = name
        self.vm = TextFileVM(id)
    }
    
    private var tip = Tip_JsonFormatter()
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
#if os(iOS)
            TextEditor(text: $vm.text)
                .padding(10)
                .disableAutocorrection(true)
#elseif os(watchOS)
            ScrollView {
                Text(vm.text)
            }
#elseif os(tvOS)
            Text(vm.text)
                .navigationTitle(name)
#endif
        }
        .navigationTitle(name)
        .task {
            vm.getFileContents(path + name)
        }
        .toolbar {
#if os(iOS)
            Button("Save") {
                vm.writeFile(vm.text, path: path + name)
            }
#endif
            
#if !os(tvOS)
            ShareLink(item: vm.text)
                .disabled(vm.text.isEmpty)
#endif
            JsonFormatterButton()
                .environment(vm)
        }
    }
}

#Preview {
    TextFile("", path: "", name: "")
}
