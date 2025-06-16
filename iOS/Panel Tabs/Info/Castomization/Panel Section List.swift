import SwiftUI

struct PanelSectionList: View {
    @Environment(PanelSectionVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.sections) { item in
                PanelSectionRow(item) {
                    vm.toggle(item)
                    vm.save()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .onMove { from, to in
                vm.move(from: from, to: to)
            }
        }
        .navigationTitle("Customize & Reorder")
        .navigationSubtitle("Reorder or hide sections to personalize your view")
        .environment(\.editMode, .constant(.active))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Reset", role: .destructive) {
                    vm.sections = vm.defaultSections
                    
                    vm.save()
                }
                .foregroundStyle(.red)
                .semibold()
            }
        }
    }
}

#Preview {
    PanelSectionList()
        .environment(PanelSectionVM())
        .darkSchemePreferred()
}
