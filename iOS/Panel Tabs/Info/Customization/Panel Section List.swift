import SwiftUI

struct PanelSectionList: View {
    @Environment(PanelSectionVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
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
            .onMove { here, there in
                vm.move(from: here, to: there)
            }
        }
        .navigationTitle("Customize & Reorder")
        .navigationSubtitle("Reorder or hide sections to personalize your view")
        .environment(\.editMode, .constant(.active))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Reset", role: .destructive) {
                    vm.sections = vm.defaultSections
                    
                    vm.save()
                }
                .foregroundStyle(.red)
            }
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
            
            ToolbarItem(placement: .bottomBar) {
                Button("Done") {
                    dismiss()
                }
                .semibold()
                .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PanelSectionList()
    }
    .darkSchemePreferred()
    .environment(PanelSectionVM())
}
