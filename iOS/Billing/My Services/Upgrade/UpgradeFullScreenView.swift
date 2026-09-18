import SwiftUI

struct UpgradeFullScreenView<Notice: View>: View {
    let packages: [ChangeablePackage]
    @Binding var selectedUpgradeId: Int?
    let isPerformingAction: Bool
    let emptyMessage: LocalizedStringKey
    let onUpgrade: () -> Void
    let notice: Notice
    
    init(
        packages: [ChangeablePackage],
        selectedUpgradeId: Binding<Int?>,
        isPerformingAction: Bool,
        emptyMessage: LocalizedStringKey = "No higher packages available right now",
        onUpgrade: @escaping () -> Void,
        @ViewBuilder notice: () -> Notice = { EmptyView() }
    ) {
        self.packages = packages
        _selectedUpgradeId = selectedUpgradeId
        self.isPerformingAction = isPerformingAction
        self.emptyMessage = emptyMessage
        self.onUpgrade = onUpgrade
        self.notice = notice()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                notice
                
                if packages.isEmpty {
                    UpgradeEmptyStateView(message: emptyMessage)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(packages) {
                            UpgradePackage(pkg: $0, selectedUpgradeId: $selectedUpgradeId)
                        }
                        
                        UpgradeActionButton(
                            planName: packages.first { $0.id == selectedUpgradeId }?.name,
                            isPerformingAction: isPerformingAction,
                            isDisabled: selectedUpgradeId == nil || isPerformingAction,
                            action: onUpgrade
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scenePadding()
    }
}
