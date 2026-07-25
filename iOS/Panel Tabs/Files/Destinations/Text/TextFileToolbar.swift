import SwiftUI

struct TextFileToolbar: View {
    @Environment(TextFileVM.self) private var vm
    @EnvironmentObject private var fileVM: FileTabVM
    @Environment(\.dismiss) private var dismiss

    @State private var alertDelete = false

    private let name, path: String

    init(_ name: String, at path: String) {
        self.name = name
        self.path = path
    }

    private var showSaveButton: Bool {
        vm.hasUnsavedChanges
    }

    var body: some View {
#if os(tvOS)
        JsonFormatterButton()
            .environment(vm)

        Menu {
            Section {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    alertDelete = true
                }
            }
        } label: {
            Image(systemName: "ellipsis")
        }
        .alert("Delete \(name)?", isPresented: $alertDelete) {
            Button("Delete", role: .destructive, action: delete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This file will be deleted permanently")
        }
#else
        if showSaveButton {
            Button("Save", action: save)
                .disabled(vm.isSaving)
                .animation(.default, value: showSaveButton)
        }

        JsonFormatterButton()
            .environment(vm)

        Section {
            Button("Delete", systemImage: "trash", role: .destructive) {
                alertDelete = true
            }
        }
        .alert("Delete \(name)?", isPresented: $alertDelete) {
            Button("Delete", role: .destructive, action: delete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This file will be deleted permanently")
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
            await vm.save()
        }
    }
}
