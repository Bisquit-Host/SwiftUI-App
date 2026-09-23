import ScrechKit

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
    
    var body: some View {
        if vm.hasUnsavedChanges {
            AsyncButton("Save", action: vm.save)
                .disabled(vm.isSaving)
                .animation(.default, value: vm.hasUnsavedChanges)
        }
        
        JsonFormatterButton()
            .environment(vm)
        
        Section {
            Button("Delete", systemImage: "trash", role: .destructive) {
                alertDelete = true
            }
        }
        .alert("Delete \(name)?", isPresented: $alertDelete) {
            AsyncButton("Delete", role: .destructive, action: delete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This file will be deleted permanently")
        }
    }
    
    private func delete() async {
        await fileVM.deleteFile(name, at: path) {
            dismiss()
        }
    }
}
