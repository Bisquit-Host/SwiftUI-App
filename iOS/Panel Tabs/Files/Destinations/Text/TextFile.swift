import SwiftUI

struct TextFile: View {
    @State private var vm: TextFileVM
    @Environment(\.panelToolbarButtonsVisible) private var toolbarButtonsVisible

    private let id, name, path: String

    init(_ id: String, name: String, at path: String) {
        self.id = id
        self.name = name
        self.path = path
        vm = TextFileVM(id, path: path + name)
    }

    var body: some View {
        VStack {
            TextFileEditor()
        }
        .navigationTitle(name)
        .task {
            await vm.start()
        }
        .onDisappear {
            vm.disconnect()
        }
        .toolbarTitleMenu {
            if toolbarButtonsVisible {
                TextFileToolbar(name, at: path)
            }
        }
        .toolbar {
#if !os(tvOS) && !os(watchOS)
            PanelToolbarItem(placement: .topBarTrailing) {
                TextFileCollaborationMenu()
            }
#endif

#if !os(tvOS)
            PanelToolbarItem(placement: .topBarTrailing) {
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
