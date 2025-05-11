import ScrechKit
import PteroNet
import QuickLooking

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
    @State private var showQuickLook = false
#warning("Destinations")
    var body: some View {
        let name = file.name
        let mimeType = file.mimetype
        
        Button {
            if !mimeType.contains("directory") {
                qlVM.getFileUrl(name, at: root)
            }
            
            //        NavigationLink {
            //            QuickLookFile(id, name: name, at: root)
            //            if mimeType.contains("directory") {
            //                //                FolderFile(id, path: root + name + "/")
            //                Text("Folder")
            //
            //            } else {
            //                Group {
            //                    if mimeType.contains("text") || mimeType.contains("json") {
            //                        //                        TextFile(id, name: name, at: root)
            //                        Text("Text")
            //
            //                    } else if mimeType.contains("video") {
            //                        //                        VideoFile(id, name: name, at: root)
            //                        Text("Video")
            //
            //                    } else if mimeType.contains("audio") {
            //                        //                        AudioPlayerView(id, name: name, at: root)
            //                        Text("AudioPlayer")
            //
            //                    } else {
            //                        //                        QuickLookFile(id, name: name, at: root)
            //                        Text("QuickLook")
            //                    }
            //                }
            //                .environmentObject(vm)
            //            }
        } label: {
            HStack {
                FileIcon(file.mimetype)
                    .semibold()
                    .frame(width: 20)
                
                Text(name)
                    .lineLimit(3)
                
                Spacer()
                
                if file.isFile {
                    let size = formatBytes(file.size)
                    
                    Text(size)
                        .footnote()
                        .secondary()
                }
            }
        }
        .quickLookPreview($showQuickLook, url: qlVM.fileUrl, blur: qlVM.isSensitive)
        .onChange(of: showQuickLook) { _, isPresented in
            if !isPresented {
                qlVM.fileUrl = nil
            }
        }
        .onChange(of: qlVM.fileUrl) { _, url in
            if let url {
                print(url.description)
                
                showQuickLook = true
            }
        }
        .buttonStyle(.plain)
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fileContextMenu(id, file: file, at: root)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
    }
}

#Preview {
    FileView("", at: "", file: sampleJSON(.fileListAttributes))
        .padding()
}
