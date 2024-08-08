import SwiftUI

struct FileIcon: View {
    private let icon: String
    private let color: Color
    
    init(_ mimeType: String, filename: String = "") {
        let (icon, color) = getFileIcon(mimeType: mimeType, filename: filename)
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        Image(systemName: icon).foregroundStyle(color)
    }
}

fileprivate func getFileIcon(mimeType: String, filename: String = "") -> (String, Color) {
    var icon = "lock.doc"
    var color = Color.gray
    
    if mimeType.contains("directory") {
        icon = "folder"
        color = .yellow
        
    } else if mimeType.contains("text") || mimeType.contains("json") {
        icon = "doc.text"
        color = .primary
        
    } else if mimeType.contains("gzip") || mimeType.contains("jar") {
        icon = "doc.zipper"
        color = .orange
        
    } else if mimeType.contains("image") {
        icon = "photo"
        color = .mint
        
    } else if mimeType.contains("video") {
        icon = "play.rectangle.fill"
        color = .red
        
    } else if mimeType.contains("pdf") {
        icon = "doc.richtext"
        color = .blue
        
    } else if mimeType.contains("audio") {
        icon = "music.note"
        color = .pink
        
    } else {
        if filename.contains(".usdz") || filename.contains(".blend") || filename.contains(".obj") {
            icon = "move.3d"
            color = .purple
        }
    }
    
    return (icon, color)
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
