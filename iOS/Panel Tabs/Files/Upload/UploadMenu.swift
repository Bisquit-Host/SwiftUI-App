import ScrechKit
import PhotosUI

struct UploadMenu: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let path: String
    
    init(_ path: String) {
        self.path = path
    }
    
    @State private var image: UIImage?
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var trigger = false
    @State private var pickerFile = false
    @State private var pickerCamera = false
    @State private var pickerLibrary = false
    @State private var sheetRemoteFile = false
    @State private var alertNewFolder = false
    @State private var newFolderName = ""
    
    var body: some View {
        Menu {
            Button("Choose File", systemImage: "folder") {
                pickerFile = true
            }
            
            Button("Take Photo", systemImage: "camera") {
                pickerCamera = true
            }
            
            Button("Photo Library", systemImage: "photo.on.rectangle") {
                pickerLibrary = true
            }
            
            Divider()
            
            AsyncButton("Directory", systemImage: "folder.badge.plus") {
                await Task.yield()
                alertNewFolder = true
            }
            
            Divider()
            
            Button("Pull remote file", systemImage: "link") {
                sheetRemoteFile = true
            }
        } label: {
            Image(systemName: "plus")
        }
        .sensoryFeedback(.success, trigger: trigger)
        .cameraPicker($pickerCamera, image: $image)
        .photosPicker(isPresented: $pickerLibrary, selection: $pickerItems, selectionBehavior: .ordered)
        .onChange(of: pickerItems) { _, newItems in
            guard !newItems.isEmpty else { return }
            pickerItems = []
            
            Task {
                await vm.handlePhotoImport(newItems, at: path)
            }
        }
        .onChange(of: image) {
            if let image {
                Task {
                    await vm.handleImageImport(image, at: path)
                }
            }
        }
        .onChange(of: vm.isUploading) { _, newValue in
            if !newValue {
                trigger.toggle()
            }
        }
        .alert("New Folder", isPresented: $alertNewFolder) {
            TextField("Enter a folder name", text: $newFolderName)
            
            AsyncButton("Create", role: .confirm) {
                let name = newFolderName
                newFolderName = ""
                
                await vm.createFolder(name, at: path)
            }
            
            Button("Cancel", role: .cancel) {
                newFolderName = ""
            }
        }
        .sheet($sheetRemoteFile) {
            NavigationStack {
                SheetRemoteFile(path)
            }
        }
        .fileImporter(isPresented: $pickerFile, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            Task {
                await vm.handleFileImportResult(result, at: path)
            }
        }
    }
}
