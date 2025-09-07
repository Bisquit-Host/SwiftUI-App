import SwiftUI

struct PanelSectionListToolbar: ViewModifier {
    @Environment(PanelSectionVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private var isDefaultSet: Bool {
        vm.sections != vm.defaultSections
    }
    
    func body(content: Content) -> some View {
        content
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

extension View {
    func panelSectionListToolbar() -> some View {
        modifier(PanelSectionListToolbar())
    }
}
