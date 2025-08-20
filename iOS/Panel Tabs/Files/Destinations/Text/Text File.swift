import SwiftUI

struct TextFile: View {
    @State private var vm: TextFileVM
    @EnvironmentObject private var fileVm: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    private let id, name, path: String
    
    init(_ id: String, name: String, at path: String) {
        self.id = id
        self.name = name
        self.path = path
        vm = TextFileVM(id)
    }
    
    private var showSaveButton: Bool {
        vm.initialText != vm.text
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            TextFileEditor()
                .environment(vm)
        }
        .navigationTitle(name)
        .task {
            await vm.getFileContents(path + name)
        }
        .toolbar {
#if os(iOS)
            if showSaveButton {
                Button("Save") {
                    save()
                }
                .animation(.default, value: showSaveButton)
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
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        delete()
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
            }
#endif
        }
    }
    
    private func delete() {
        Task {
            await fileVm.deleteFile(name, at: path) {
                dismiss()
            }
        }
    }
    
    private func save() {
        Task {
            await vm.writeFile(vm.text, at: path + name)
        }
    }
}

#Preview {
    TextFile("", name: "Preview", at: "")
        .darkSchemePreferred()
        .environmentObject(FileTabVM(""))
}
