import SwiftUI

struct TextFileCollaborationMenu: View {
    @Environment(TextFileVM.self) private var vm

    var body: some View {
        if vm.isCollaborating, vm.participants.count > 1 {
            Menu {
                ForEach(vm.participants) {
                    Label($0.name, systemImage: "person.crop.circle")
                }
            } label: {
                Label("\(vm.participants.count) editors", systemImage: "person.2.fill")
            }
            .labelStyle(.iconOnly)
            .accessibilityLabel("\(vm.participants.count) people editing")
        }
    }
}

#Preview {
    TextFileCollaborationMenu()
        .environment(TextFileVM(""))
}
