import SwiftUI
import PteroNet

struct FilePermissionsView: View {
    @EnvironmentObject private var vm: FileTabVM
    
    @Environment(\.dismiss) private var dismiss
    
    private let file: FileAttributes
    private let root: String
    
    init(_ file: FileAttributes, at root: String) {
        self.file = file
        self.root = root
    }
    
    @State private var systemRead = false
    @State private var systemWrite = false
    @State private var systemExecute = false
    @State private var adminRead = false
    @State private var adminWrite = false
    @State private var adminExecute = false
    @State private var otherRead = false
    @State private var otherWrite = false
    @State private var otherExecute = false
    
    private var newMode: String {
        vm.chmod(systemRead, systemWrite, systemExecute) +
        vm.chmod(adminRead, adminWrite, adminExecute) +
        vm.chmod(otherRead, otherWrite, otherExecute)
    }
    
    private var isDifferent: Bool {
        file.modeBits != newMode
    }
    
    @State private var newModeBits = ""
    
    var body: some View {
        let oldBits = Text(file.modeBits)
            .monospaced()
        
        let newBits = Text(newMode)
            .monospaced()
        
        List {
            TextField("777", text: $newModeBits)
            
            Section("System") {
                Toggle("Read", isOn: $systemRead)
                Toggle("Write", isOn: $systemWrite)
                Toggle("Execute", isOn: $systemExecute)
            }
            
            Section("Admin") {
                Toggle("Read", isOn: $adminRead)
                Toggle("Write", isOn: $adminWrite)
                Toggle("Execute", isOn: $adminExecute)
            }
            
            Section("Other users") {
                Toggle("Read", isOn: $otherRead)
                Toggle("Write", isOn: $otherWrite)
                Toggle("Execute", isOn: $otherExecute)
            }
            
            Button {
                if isDifferent {
                    Task {
                        await vm.changeChmod(file.name, at: root, mode: newMode) {
                            dismiss()
                        }
                    }
                } else {
                    dismiss()
                }
            } label: {
                Text(isDifferent ? "Update \(oldBits) to \(newBits)" : "Cancel")
                    .numericTransition()
                    .animation(.default, value: newMode)
                    .foregroundStyle(.foreground)
            }
        }
        .navigationTitle("Permissions")
        .toolbarTitleDisplayMode(.inline)
        .onChange(of: newMode) {
            newModeBits = newMode
        }
        .onChange(of: newModeBits) { _, newValue in
            if newValue.count == 3 {
                let newValues = parsePermissions(newValue)
                
                systemRead = newValues.systemRead
                systemWrite = newValues.systemWrite
                systemExecute = newValues.systemExecute
                adminRead = newValues.adminRead
                adminWrite = newValues.adminWrite
                adminExecute = newValues.adminExecute
                otherRead = newValues.otherRead
                otherWrite = newValues.otherWrite
                otherExecute = newValues.otherExecute
            }
        }
        .task {
            newModeBits = file.modeBits
            
            let bits = Array(file.mode)
            
            systemRead = initBit(bits[1])
            systemWrite = initBit(bits[2])
            systemExecute = initBit(bits[3])
            adminRead = initBit(bits[4])
            adminWrite = initBit(bits[5])
            adminExecute = initBit(bits[6])
            otherRead = initBit(bits[7])
            otherWrite = initBit(bits[8])
            otherExecute = initBit(bits[9])
        }
    }
    
    private func initBit(_ letter: Character) -> Bool {
        letter != "-"
    }
    
    private func parsePermissions(_ modeBits: String) -> (
        systemRead: Bool,
        systemWrite: Bool,
        systemExecute: Bool,
        adminRead: Bool,
        adminWrite: Bool,
        adminExecute: Bool,
        otherRead: Bool,
        otherWrite: Bool,
        otherExecute: Bool
    ) {
        let permissions = modeBits.compactMap {
            UInt8(String($0), radix: 8)
        }
        
        func extractPermissions(_ value: UInt8) -> (Bool, Bool, Bool) {
            (value & 4 != 0, value & 2 != 0, value & 1 != 0)
        }
        
        let (systemRead, systemWrite, systemExecute) = extractPermissions(permissions[safe: 0] ?? 0)
        let (adminRead, adminWrite, adminExecute) = extractPermissions(permissions[safe: 1] ?? 0)
        let (otherRead, otherWrite, otherExecute) = extractPermissions(permissions[safe: 2] ?? 0)
        
        return (
            systemRead, systemWrite, systemExecute,
            adminRead, adminWrite, adminExecute,
            otherRead, otherWrite, otherExecute
        )
    }
}

fileprivate extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    FilePermissionsView(
        sampleJSON(.fileListAttributes),
        at: ""
    )
    .environmentObject(FileTabVM(""))
}
