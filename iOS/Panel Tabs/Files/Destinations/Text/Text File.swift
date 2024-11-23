import ScrechKit

struct TextFile: View {
    private var vm: TextFileVM
    
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
            Button {
                vm.writeFile(vm.text, path: path + name)
            } label: {
                Text("Save changes")
                    .foregroundStyle(.yellow)
                    .title2(.bold)
                    .padding(10)
                    .overlay {
                        Capsule()
                            .stroke(.gray.opacity(0.5), lineWidth: 3)
                    }
            }
            
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
            ShareLink(item: vm.text)
                .disabled(vm.text.isEmpty)
            
            if vm.showPrettyButton {
                Button {
                    tip.invalidate(reason: .actionPerformed)
                    vm.makePretty()
                } label: {
                    Image(systemName: "ellipsis.curlybraces")
                }
#if !os(watchOS)
                .popoverTip(tip) { action in
                    if action.id == "format-json" {
                        vm.makePretty()
                    }
                }
#endif
            }
        }
    }
}

#Preview {
    TextFile("", path: "", name: "")
}
