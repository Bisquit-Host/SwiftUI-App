import SwiftUI

struct NewFolder: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let root: String
    
    init(_ root: String) {
        self.root = root
    }
    
    @State private var alertCreate = false
    @State private var newFolderName = ""
    
    var body: some View {
        Button {
            alertCreate = true
        } label: {
            HStack {
                Text("New folder")
                
                Spacer()
                
                Image(systemName: "folder.badge.plus")
            }
        }
        .alert("New Folder", isPresented: $alertCreate) {
            TextField("", text: $newFolderName)
            
            Button("Create") {
                Task {
                    await vm.createFolder(newFolderName, at: root)
                }
                
                newFolderName = ""
            }
            
            Button("Cancel") {
                newFolderName = ""
            }
        }
    }
}

//#Preview {
//    List {
//        ButtonNewFolder("")
//    }
//    .environmentObject(FileTabVM(""))
//}
