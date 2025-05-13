import ScrechKit

struct UploadMenu: View {
    @EnvironmentObject private var vm: FileTabVM
    
    @Binding private var image: UIImage?
    private let path: String
    
    init( _ image: Binding<UIImage?>, at path: String) {
        _image = image
        self.path = path
    }
    
    @State private var showFilePicker = false
    @State private var showCameraPicker = false
    @State private var showImagePicker = false
    @State private var sheetRemoteFile = false
    @State private var urls: [URL] = []
    
    var body: some View {
        Menu {
            MenuButton("Choose File", icon: "folder") {
                showFilePicker = true
            }
            
            MenuButton("Take Photo", icon: "camera") {
                showCameraPicker = true
            }
            
            MenuButton("Photo Library", icon: "photo.on.rectangle") {
                showImagePicker = true
            }
            
            Divider()
            
            Button {
                sheetRemoteFile = true
            } label: {
                Label("Pull remote file", systemImage: "link")
            }
        } label: {
            HStack {
                Text("Upload file")
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .title3(.semibold)
            }
            .foregroundStyle(.foreground)
        }
        .cameraPicker($showCameraPicker, image: $image)
        .libraryPicker($showImagePicker, title: "Drag & Drop", subtitle: "Tap to add an Image")
        .sheet($vm.sheetPreview) {
            UploadPreview(urls, at: path)
        }
        .sheet($sheetRemoteFile) {
            SheetRemoteFile(path)
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let model):
                urls = model
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            vm.sheetPreview = true
        }
    }
}
