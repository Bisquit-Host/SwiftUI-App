import SwiftUI

struct FileIconView: View {
    private let mimeType: String
    
    init(_ mimetype: String) {
        self.mimeType = mimetype
    }
    
    var body: some View {
        Group {
            if mimeType.contains("directory") {
                Image(systemName: "folder")
                    .foregroundStyle(.yellow)
                
            } else if mimeType.contains("text") || mimeType.contains("json") {
                Image(systemName: "doc.text")
                    .foregroundStyle(.primary)
                
            } else if mimeType.contains("gzip") {
                Image(systemName: "doc.zipper")
                    .foregroundStyle(.orange)
                
            } else if mimeType.contains("image") {
                Image(systemName: "photo")
                    .foregroundStyle(.mint)
                
            } else if mimeType.contains("video") {
                Image(systemName: "play.rectangle.fill")
                    .foregroundStyle(.red)
                    .padding(-5)
                    .background(.white)
                
            } else if mimeType.contains("pdf") {
                Image(systemName: "doc.richtext")
                    .foregroundStyle(.blue)
                
            } else {
                Image(systemName: "lock.doc")
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    FileIconView("video")
}
