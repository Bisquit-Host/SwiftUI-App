import SwiftUI
import QuickLooking

struct UploadPreviewList: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private let urls: [URL]
    
    init(_ urls: [URL]) {
        self.urls = urls
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
