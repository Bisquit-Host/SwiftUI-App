import SwiftUI

struct NewFolder: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let path: String
    
    init(_ path: String) {
        self.path = path
    }
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Button {
            withAnimation {
                vm.showTextField.toggle()
                isFocused = true
            }
        } label: {
            HStack {
                Text("New folder")
                
                Spacer()
                
                Image(systemName: vm.showTextField ? "chevron.down" : "folder.badge.plus")
                    .title3(.semibold)
            }
            .foregroundStyle(.foreground)
        }
        .keyboardShortcut("N", modifiers: .command)
        
        if vm.showTextField {
            TextField("New folder", text: $vm.newFolderName)
                .semibold()
                .autocorrectionDisabled()
                .focused($isFocused)
                .onSubmit {
                    if !vm.newFolderName.isEmpty {
                        vm.createFolder(vm.newFolderName, root: path)
                    }
                    
                    vm.showTextField = false
                    vm.newFolderName = ""
                }
        }
    }
}

#Preview {
    List {
        NewFolder("")
    }
    .environmentObject(FileTabVM(""))
}
