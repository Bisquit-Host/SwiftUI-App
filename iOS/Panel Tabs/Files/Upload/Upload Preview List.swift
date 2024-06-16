import SwiftUI

struct UploadPreviewList: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let urls: [URL]
    
    init(_ urls: [URL]) {
        self.urls = urls
    }
    
    init(_ url: URL) {
        urls = [url]
    }
    
    var body: some View {
        ForEach(urls, id: \.self) { url in
            QuickLookView(url)
        }
    }
}

#Preview {
    UploadPreviewList([])
}
