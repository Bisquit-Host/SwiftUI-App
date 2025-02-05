import ScrechKit

struct UploadPreview: View {
    @EnvironmentObject private var vm: FileTabVM
    
    @Environment(\.dismiss) private var dismiss
    
    private let urls: [URL]
    private let root: String
    
    init(_ urls: [URL], root: String = "") {
        self.urls = urls
        self.root = root
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel", role: .destructive) {
                    vm.sheetPreview = false
                }
                
                Spacer()
                
                Button("Upload") {
                    vm.handleFileImport(urls, root: root)
                    dismiss()
                }
            }
            .semibold()
            .padding(20)
            .background(.ultraThinMaterial)
            
            if urls.count > 1 {
                Text("\(urls.count - 1) more files")
                    .padding()
            }
            
            if let last = urls.last {
                UploadPreviewList(last)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    UploadPreview([
        URL(string: "https://file-examples.com/wp-content/storage/2017/02/file_example_XLS_10.xls")!
    ])
    .environmentObject(FileTabVM(""))
}
