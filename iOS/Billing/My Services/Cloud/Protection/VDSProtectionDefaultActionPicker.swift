import SwiftUI
import BisquitoNet

struct VDSProtectionDefaultActionPicker: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    @Binding private var selectedAction: VDSProtectionDefaultAction
    
    init(_ selectedAction: Binding<VDSProtectionDefaultAction>) {
        _selectedAction = selectedAction
    }
    
    var body: some View {
        HStack {
            Text("Default action")
                .subheadline(.semibold)
            
            Spacer()
            
            Menu {
                ForEach(VDSProtectionDefaultAction.menuCases) { action in
                    Button {
                        selectedAction = action
                    } label: {
                        if selectedAction == action {
                            Label(action.title, systemImage: "checkmark")
                        } else {
                            Text(action.title)
                        }
                        
                        if !action.canBeSetFromApp {
                            Text("Can only be set by an admin")
                        }
                    }
                    .disabled(!action.canBeSetFromApp)
                }
            } label: {
                HStack(spacing: 8) {
                    Text(selectedAction.title)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .footnote(.semibold)
                        .secondary()
                }
            }
            .foregroundStyle(.foreground)
            .disabled(vm.isPerformingAction)
        }
    }
}
