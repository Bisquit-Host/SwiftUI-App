import ScrechKit

struct TextFile: View {
    @State private var vm: TextFileVM
    @EnvironmentObject private var fileVm: FileTabVM
    
    @Environment(\.dismiss) private var dismiss
    
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
#if os(watchOS)
            ScrollView {
                Text(vm.text)
            }
#elseif os(tvOS)
            Text(vm.text)
#else
            TextEditor(text: $vm.text)
                .disableAutocorrection(true)
                .autocapitalization(.none)
#endif
        }
        .navigationTitle(name)
        .task {
            vm.getFileContents(path + name)
        }
        .toolbar {
#if os(iOS)
            if vm.initialText != vm.text {
                Button("Save") {
                    vm.writeFile(vm.text, path: path + name)
                }
            }
#endif
            JsonFormatterButton()
                .environment(vm)
#if !os(watchOS)
            Menu {
#if !os(tvOS)
                ShareLink(item: vm.text)
                    .disabled(vm.text.isEmpty)
#endif
                Section {
                    Button(role: .destructive) {
                        fileVm.deleteFile(name, at: path) {
                            dismiss()
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
#endif
        }
    }
}

#Preview {
    TextFile("", path: "", name: "")
        .environmentObject(FileTabVM(""))
}
