import SwiftUI

#warning("Remove? Debug?")
struct TempDir: View {
    @State private var fileNames: [String] = []
    
    var body: some View {
        List {
            Section {
                Text("\(fileNames.count) files")
            }
            
            ForEach(fileNames, id: \.self) { fileName in
                Text(fileName)
            }
            .navigationTitle("Temporary Files")
            .task {
                loadFiles()
            }
        }
    }
    
    private func loadFiles() {
        let tempDirectory = FileManager.default.temporaryDirectory
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: tempDirectory.path)
            fileNames = files
        } catch {
            print("Failed to load temporary directory files:", error.localizedDescription)
        }
    }
}
#Preview {
    TempDir()
}
