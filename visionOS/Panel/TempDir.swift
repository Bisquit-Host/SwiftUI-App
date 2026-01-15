import SwiftUI
import os

struct TempDir: View {
    @State private var fileNames: [String] = []
    
    var body: some View {
        List {
            Section {
                Text("Files \(fileNames.count)")
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
            fileNames = try FileManager.default.contentsOfDirectory(atPath: tempDir.path)
        } catch {
            Logger().error("Failed to load temp dir files: \(error)")
        }
    }
}

#Preview {
    TempDir()
}
