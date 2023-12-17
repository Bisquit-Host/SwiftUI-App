import ScrechKit

struct FileTab_Formats: View {
    private let formats = [
        "directory",
        "gzip",
        "text",
        "image",
        "video",
        "pdf",
        "unsupported files"
    ]
    
    var body: some View {
        DisclosureGroup("All supported data formats") {
            ForEach(formats, id: \.self) { format in
                HStack {
                    FileIconView(format)
                        .semibold()
                        .frame(width: 20)
                    
                    Text(format)
                }
            }
        }
    }
}

#Preview {
    FileTab_Formats()
}
