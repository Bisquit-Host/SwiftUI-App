import ScrechKit

struct Upload_Menu: View {
    @EnvironmentObject private var vm: FileTabVM
    
    @Binding private var image: UIImage?
    private let path: String
    
    init(_ image: Binding<UIImage?>, path: String) {
        _image = image
        self.path = path
    }
    
    @State private var showFilePicker = false
    @State private var showCameraPicker = false
    @State private var showImagePicker = false
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
        } label: {
            HStack {
                Text("Upload file")
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .title3(.semibold)
            }
            .foregroundStyle(.foreground)
        }
        .sheet($vm.sheetPreview) {
            UploadPreview(urls, path: path)
        }
        .imagePicker($showImagePicker, image: $image)
        .cameraPicker($showCameraPicker, image: $image)
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
