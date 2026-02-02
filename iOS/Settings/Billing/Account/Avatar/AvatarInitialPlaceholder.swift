import SwiftUI

struct AvatarInitialPlaceholder: View {
    private let initial: String
    
    init(_ user: BillingUser) {
        self.initial = user.name.first.map { String($0) } ?? "?"
    }
    
    var body: some View {
        Circle()
            .fill(.blue.opacity(0.12))
            .overlay {
                Text(initial.uppercased())
                    .title3(.semibold)
                    .foregroundStyle(.blue)
            }
    }
}

#Preview {
    AvatarInitialPlaceholder(.preview)
        .darkSchemePreferred()
}
