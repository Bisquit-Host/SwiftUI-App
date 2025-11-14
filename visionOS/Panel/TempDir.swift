import SwiftUI

struct TempDir: View {
    @State private var fileNames: [String] = []
    
    var body: some View {
        List {
            Section {
                Text(.files(fileNames.count))
            }
            
            ForEach(fileNames, id: \.self) {
                Text($0)
            }
        }
        .navigationTitle("Temporary Files")
        .task {
            loadFiles()
        }
    }
    
    private func loadFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            fileNames = try FileManager.default.contentsOfDirectory(
                atPath: tempDir.path
            )
        } catch {
            print("Failed to load temp dir files:", error.localizedDescription)
        }
    }
}
#Preview {
    TempDir()
}
