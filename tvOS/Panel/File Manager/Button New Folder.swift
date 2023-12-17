import SwiftUI

struct ButtonNewFolder: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let path: String
    
    init(_ path: String) {
        self.path = path
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
                vm.createFolder(newFolderName,
                                path: path
                )
                
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
