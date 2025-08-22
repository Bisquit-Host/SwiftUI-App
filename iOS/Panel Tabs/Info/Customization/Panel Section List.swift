import SwiftUI

struct PanelSectionList: View {
    @Environment(PanelSectionVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private var isDefaultSet: Bool {
        vm.sections != vm.defaultSections
    }
    
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
            if isDefaultSet {
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        vm.sections = vm.defaultSections
                        vm.save()
                    } label: {
                        Text("Reset")
                            .semibold()
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.red)
                }
            }
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
            
            ToolbarItem(placement: .bottomBar) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .semibold()
                        .foregroundStyle(.white)
                }
                .buttonStyle(.glassProminent)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PanelSectionList()
    }
    .environment(PanelSectionVM())
}
