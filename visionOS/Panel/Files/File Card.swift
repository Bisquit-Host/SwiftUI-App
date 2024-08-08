import SwiftUI
import PteroNet

struct FileCard: View {
    @EnvironmentObject private var vm: FileTabVM
    //    @Environment(NavState.self) private var navState
    //    @EnvironmentObject private var settings: SettingsStorage
    
    private let id, root: String
    private let file: FileAttributes
    
    init(
        _ id: String,
        file: FileAttributes,
        root: String = ""
    ) {
        self.id = id
        self.file = file
        self.root = root
    }
    
    var body: some View {
        NavigationLink {
//            FileList(id, root: root + file.name)
//                .environmentObject(vm)
        } label: {
            HStack {
                FileIcon(file.mimetype, filename: file.name)
                
                Text(file.name)
            }
        }
    }
}

#Preview {
    List {
        FileCard("", file: sampleJSON(.fileListAttributes), root: "")
            .environment(NavState())
    }
}
