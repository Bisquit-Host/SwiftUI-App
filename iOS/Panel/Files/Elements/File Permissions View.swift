import SwiftUI

struct FilePermissionsView: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    private let mode: String
    private let root: String
    private let name: String
    
    init(_ mode: String, root: String, name: String) {
        self.mode = mode
        self.root = root
        self.name = name
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
    
    var body: some View {
        List {
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
                vm.changeChmod(newMode, root: root, name: name) {
                    dismiss()
                }
            } label: {
                Text("Update")
            }
        }
        .task {
            let bits = Array(mode)
            
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
    
    func initBit(_ letter: Character) -> Bool {
        letter != "-"
    }
}

#Preview {
    FilePermissionsView("drwxr-x---", root: "", name: "")
        .environmentObject(FileTabVM(""))
}
