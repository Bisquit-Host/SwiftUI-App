import SwiftUI

struct BillingSectionCard<Content: View, PrimaryButton: View>: View {
    private let title: LocalizedStringKey?
    private let showsBackground: Bool
    private let content: Content
    private let primaryButton: PrimaryButton?
    
    init(
        _ title: LocalizedStringKey? = nil,
        showsBackground: Bool = true,
        @ViewBuilder content: () -> Content,
        @ViewBuilder primaryButton: () -> PrimaryButton
    ) {
        self.title = title
        self.showsBackground = showsBackground
        self.content = content()
        self.primaryButton = primaryButton()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if title != nil || primaryButton != nil {
                HStack {
                    if let title {
                        Text(title)
                            .headline()
                    }
                    
                    Spacer()
                    
                    if let primaryButton {
                        primaryButton
                    }
                }
            }
            
            content
        }
        .padding(16)
        .background {
            if showsBackground {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background.opacity(0.6))
            }
        }
        .overlay {
            if showsBackground {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.primary.opacity(0.04), lineWidth: 1)
            }
        }
    }
}

extension BillingSectionCard where PrimaryButton == EmptyView {
    init(
        _ title: LocalizedStringKey? = nil,
        showsBackground: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.showsBackground = showsBackground
        self.content = content()
        self.primaryButton = nil
    }
}

#Preview {
    BillingSectionCard("Preview") {
        Text("Content")
    }
    .padding()
    .darkSchemePreferred()
}
