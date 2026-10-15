import ScrechKit
import OSLog

struct DatabaseInstanceExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private let export: DatabaseInstanceExport
    
    init(_ export: DatabaseInstanceExport) {
        self.export = export
    }
    
    @State private var fileURL: URL?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(export.contents.isEmpty ? String(localized: "Export is empty") : export.contents)
                    .monospaced()
                    .footnote()
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle(export.name)
            .toolbarTitleDisplayMode(.inline)
            .task {
                fileURL = writeFile()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", role: .close) {
                        dismiss()
                    }
                }
                
                if let fileURL {
                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(item: fileURL)
                    }
                }
            }
        }
    }
    
    private func writeFile() -> URL? {
        let url = URL.temporaryDirectory.appending(path: "\(export.name.replacing("/", with: "-")).sql")
        
        do {
            try export.contents.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            Logger().error("Failed to write database export: \(error.localizedDescription)")
            return nil
        }
    }
}

#Preview {
    DatabaseInstanceExportSheet(DatabaseInstanceExport(name: "main", contents: "CREATE TABLE players (id INT);"))
        .darkSchemePreferred()
}
