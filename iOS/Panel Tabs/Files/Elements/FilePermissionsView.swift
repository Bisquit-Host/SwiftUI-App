import ScrechKit
import Calagopus

struct FilePermissionsView: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    private let file: CalagopusFileEntry
    private let root: String
    
    init(_ file: CalagopusFileEntry, at root: String) {
        self.file = file
        self.root = root
        _permissions = State(initialValue: FilePermissionsVM(mode: file.mode, modeBits: file.modeBits))
    }
    
    @State private var permissions: FilePermissionsVM
    
    var body: some View {
        @Bindable var permissions = permissions
        
        let oldBits = Text(permissions.originalMode)
            .monospaced()
        
        let newBits = Text(permissions.validatedMode ?? permissions.modeInput)
            .monospaced()
        
        List {
            TextField("777", text: $permissions.modeInput)
                .limitInputLength($permissions.modeInput, length: 4)
                .keyboardType(.numberPad)
            
            Section("System") {
                Toggle("Read", isOn: $permissions.systemRead)
                Toggle("Write", isOn: $permissions.systemWrite)
                Toggle("Execute", isOn: $permissions.systemExecute)
            }
            
            Section("Admin") {
                Toggle("Read", isOn: $permissions.adminRead)
                Toggle("Write", isOn: $permissions.adminWrite)
                Toggle("Execute", isOn: $permissions.adminExecute)
            }
            
            Section("Other users") {
                Toggle("Read", isOn: $permissions.otherRead)
                Toggle("Write", isOn: $permissions.otherWrite)
                Toggle("Execute", isOn: $permissions.otherExecute)
            }
            
            AsyncButton(action: updateChmod) {
                Group {
                    if permissions.isDifferent {
                        Text("Update \(oldBits) to \(newBits)")
                    } else {
                        Text("Cancel")
                    }
                }
                .numericTransition()
                .animation(.default, value: permissions.modeInput)
                .foregroundStyle(.foreground)
            }
            .disabled(!permissions.isValid)
        }
        .navigationTitle("Permissions")
    }
    
    private func updateChmod() async {
        guard let mode = permissions.validatedMode else { return }
        
        if permissions.isDifferent {
            await vm.changeChmod(file.name, at: root, mode: mode) {
                dismiss()
            }
        } else {
            dismiss()
        }
    }
    
}

#Preview {
    NavigationStack {
        FilePermissionsView(PreviewProp.fileAttributes, at: "")
    }
    .darkSchemePreferred()
    .environmentObject(FileTabVM(""))
}
