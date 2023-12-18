import ScrechKit

struct UploadPreview: View {
    @EnvironmentObject private var vm: FileTabVM
    @Environment(\.dismiss) private var dismiss
    
    private let urls: [URL]
    private let path: String
    
    init(_ urls: [URL], path: String = "") {
        self.urls = urls
        self.path = path
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel", role: .destructive) {
                    vm.sheetPreview = false
                }
                
                Spacer()
                
                Button("Upload") {
                    vm.handleFileImport(urls, directory: path)
                    dismiss()
                }
            }
            .semibold()
            .padding(20)
            .background(.ultraThinMaterial)
            
            ForEach(urls, id: \.self) { url in
                QuickLookView(url)
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
