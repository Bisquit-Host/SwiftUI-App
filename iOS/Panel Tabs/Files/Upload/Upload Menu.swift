import ScrechKit

struct UploadMenu: View {
    @EnvironmentObject private var vm: FileTabVM
    
    @Binding private var image: UIImage?
//    @Binding private var url: URL?
    private let root: String
    
    init(
        _ image: Binding<UIImage?>,
//        url: Binding<URL?>,
        root: String
    ) {
        _image = image
//        _url = url
        self.root = root
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
            UploadPreview(urls, root: root)
        }
        .sheet($sheetRemoteFile) {
            SheetRemoteFile(root)
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
