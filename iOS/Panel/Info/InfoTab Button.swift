import SwiftUI

struct InfoTabButton: View {
    private let title: LocalizedStringResource
    private let icon: String
    private let action: () -> Void
    
    init(_ title: LocalizedStringResource,
         icon: String,
         action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .rounded()
                
                Spacer()
                
                Image(systemName: icon)
                    .title2()
            }
            .frame(height: 25)
            .foregroundStyle(.foreground)
            .padding()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        }
    }
}

#Preview {
    InfoTabButton("Preview", icon: "person.3") {}
}
