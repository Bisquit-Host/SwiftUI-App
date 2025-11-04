import SwiftUI

struct SubdomainCreateButton: View {
    @Binding private var sheetCreate: Bool
    
    init(_ sheetCreate: Binding<Bool>) {
        _sheetCreate = sheetCreate
    }
    
    var body: some View {
        Section {
            Button {
                sheetCreate = true
            } label: {
                Image(systemName: "link.badge.plus")
                    .foregroundStyle(.foreground)
                    .bold()
                    .frame(30)
                    .background(.ultraThinMaterial.opacity(0.3), in: .circle)
                    .overlay {
                        Circle()
                            .stroke(.gray.opacity(0.25), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .keyboardShortcut("n", modifiers: [.command, .shift])
        }
    }
}

#Preview {
    List {
        SubdomainCreateButton(.constant(false))
    }
    .darkSchemePreferred()
}
