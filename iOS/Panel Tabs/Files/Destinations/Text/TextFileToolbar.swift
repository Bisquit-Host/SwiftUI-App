import SwiftUI

struct TextFileToolbar: View {
    @Environment(TextFileVM.self) private var vm
    @EnvironmentObject private var fileVM: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    private let name, path: String
    
    init(_ name: String, at path: String) {
        self.name = name
        self.path = path
    }
    
    private var showSaveButton: Bool {
        vm.initialText != vm.text
    }
    
    var body: some View {
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
    
    private func delete() {
        Task {
            await fileVM.deleteFile(name, at: path) {
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
