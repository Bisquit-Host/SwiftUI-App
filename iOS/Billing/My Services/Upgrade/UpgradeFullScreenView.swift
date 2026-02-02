import SwiftUI

struct UpgradeFullScreenView<Notice: View, Summary: View>: View {
    let packages: [ChangeablePackage]
    @Binding var selectedUpgradeId: Int?
    let isPerformingAction: Bool
    let buttonTitle: String
    let buttonSubtitle: String?
    let emptyMessage: LocalizedStringKey
    let onUpgrade: () -> Void
    let notice: Notice
    let summary: Summary
    
    init(
        packages: [ChangeablePackage],
        selectedUpgradeId: Binding<Int?>,
        isPerformingAction: Bool,
        buttonTitle: String,
        buttonSubtitle: String?,
        emptyMessage: LocalizedStringKey = "No higher packages available right now",
        onUpgrade: @escaping () -> Void,
        @ViewBuilder notice: () -> Notice = { EmptyView() },
        @ViewBuilder summary: () -> Summary = { EmptyView() }
    ) {
        self.packages = packages
        _selectedUpgradeId = selectedUpgradeId
        self.isPerformingAction = isPerformingAction
        self.buttonTitle = buttonTitle
        self.buttonSubtitle = buttonSubtitle
        self.emptyMessage = emptyMessage
        self.onUpgrade = onUpgrade
        self.notice = notice()
        self.summary = summary()
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
                        
                        summary
                        
                        UpgradeActionButton(
                            title: buttonTitle,
                            subtitle: buttonSubtitle,
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
