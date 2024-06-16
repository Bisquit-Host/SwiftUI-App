import ScrechKit

struct UploadMenu: View {
    @EnvironmentObject private var vm: FileTabVM
    
    @Binding private var url: URL?
    @Binding private var image: UIImage?
    private let root: String
    
    init(
        _ image: Binding<UIImage?>,
        url: Binding<URL?>,
        root: String
    ) {
        _image = image
        _url = url
        self.root = root
    }
    
    @State private var showFilePicker = false
    @State private var showCameraPicker = false
    @State private var showImagePicker = false
    @State private var alertRemoteFile = false
    @State private var remoteFileUrl = ""
    @State private var remoteFileName = ""
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
            
            Menu {
                Button("Paste") {
                    if let url = UIPasteboard.general.string {
                        vm.pullRemoteFile(url, directory: root)
                    }
                }
                
                Button("Enter manually") {
                    alertRemoteFile = true
                }
            } label: {
                Label("Pull Remote File", systemImage: "link")
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
        .alert("Pull Remote File", isPresented: $alertRemoteFile) {
            TextField("Name", text: $remoteFileName)
                .autocorrectionDisabled()
            
            TextField("Link", text: $remoteFileUrl)
            
            Button("Confirm") {
#warning("Arguments usage")
                vm.pullRemoteFile(remoteFileUrl, directory: root)
            }
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
