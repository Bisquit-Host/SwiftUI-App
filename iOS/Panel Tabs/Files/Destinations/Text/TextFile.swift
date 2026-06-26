import SwiftUI

struct TextFile: View {
    @State private var vm: TextFileVM
    
    private let id, name, path: String
    
    init(_ id: String, name: String, at path: String) {
        self.id = id
        self.name = name
        self.path = path
        vm = TextFileVM(id)
    }
    
    var body: some View {
        VStack {
            TextFileEditor()
        }
        .navigationTitle(name)
        .task {
            await vm.getFileContents(path + name)
        }
        .toolbarTitleMenu {
            TextFileToolbar(name, at: path)
        }
        .toolbar {
#if !os(tvOS)
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: vm.text)
                    .disabled(vm.text.isEmpty)
            }
#endif
        }
        .environment(vm)
    }
}

#Preview {
    NavigationStack {
        TextFile("", name: "Preview", at: "")
    }
    .darkSchemePreferred()
    .environmentObject(FileTabVM(""))
}
