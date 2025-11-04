import SwiftUI

struct PanelSectionList: View {
    @Environment(PanelSectionVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                Text("Reorder or hide sections to personalize your view")
                    .secondary()
            }
            .listRowBackground(Color.clear)
            
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
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Reset", role: .destructive) {
                    vm.sections = vm.defaultSections
                    vm.save()
                }
                .foregroundStyle(.red)
                .semibold()
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                    vm.save()
                }
                .semibold()
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
