import SwiftUI

struct FileIcon: View {
    private let filename: String
    private let mimeType: String
    
    init(_ mimeType: String, filename: String = "") {
        self.mimeType = mimeType
        self.filename = filename
    }
    
    var body: some View {
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
            
        } else if mimeType.contains("audio") {
            Image(systemName: "music.note")
                .foregroundStyle(.pink)
            
        } else {
            if filename.contains(".usdz") || filename.contains(".blend") || filename.contains(".obj") {
                Image(systemName: "move.3d")
                    .foregroundStyle(.purple)
                
            } else {
                Image(systemName: "lock.doc")
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    List {
        FileIcon("directory")
        FileIcon("json")
        FileIcon("gzip")
        FileIcon("image")
        FileIcon("video")
        FileIcon("pdf")
        FileIcon("audio")
        FileIcon("", filename: ".usdz")
        FileIcon("lock.doc")
    }
}
