import ScrechKit
import PteroNet
import QuickLook

struct NavTest {
    private let id, root: String
    private let file: FileAttributes
    
    init(_ id: String, at root: String, file: FileAttributes) {
        self.id = id
        self.root = root
        self.file = file
    }
}

struct FileView: View {
    @State private var qlVM: QuickLookFileVM
    @EnvironmentObject private var vm: FileTabVM
    
    private let id, root: String
    private let file: FileAttributes
    
    init(_ id: String, at root: String, file: FileAttributes) {
        self.id = id
        self.root = root
        self.file = file
        qlVM = QuickLookFileVM(id)
    }
    
    //    @State private var sheetMetadata = false
    @State private var showPreview = false
    
    var body: some View {
        let name = file.name
        let mimeType = file.mimetype
        
        VStack {
            if mimeType.contains("directory") {
#if DEBUG
                NavigationLink(value: root + "/" + name) {
                    FileCard(file)
                }
#else
                FileCard(file)
#endif
            } else {
                Button {
                    Task {
                        await qlVM.getFileUrl(name, at: root)
                    }
                    
                    //        NavigationLink {
                    //            QuickLookFile(id, name: name, at: path)
                    //            if mimeType.contains("directory") {
                    //                //                FolderFile(id, path: path + name + "/")
                    //                Text("Folder")
                    //
                    //            } else {
                    //                Group {
                    //                    if mimeType.contains("text") || mimeType.contains("json") {
                    //                        //                        TextFile(id, name: name, at: path)
                    //                        Text("Text")
                    //
                    //                    } else if mimeType.contains("video") {
                    //                        //                        VideoFile(id, name: name, at: path)
                    //                        Text("Video")
                    //
                    //                    } else if mimeType.contains("audio") {
                    //                        //                        AudioPlayerView(id, name: name, at: path)
                    //                        Text("AudioPlayer")
                    //
                    //                    } else {
                    //                        //                        QuickLookFile(id, name: name, at: path)
                    //                        Text("QuickLook")
                    //                    }
                    //                }
                    //                .environmentObject(vm)
                    //            }
                } label: {
                    FileCard(file)
                }
            }
        }
        .quickLookPreview($qlVM.fileUrl)
        .buttonStyle(.plain)
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fileContextMenu(id, file: file, at: root)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
        .onChange(of: showPreview) { _, isPresented in
            if !isPresented {
                qlVM.fileUrl = nil
            }
        }
        .onChange(of: qlVM.fileUrl) { _, url in
            guard let url else {
                return
            }
            
            print(url.description)
            showPreview = true
        }
    }
}

#Preview {
    FileView("", at: "", file: PreviewProp.fileAttributes)
        .padding()
        .darkSchemePreferred()
        .environmentObject(FileTabVM(""))
}
