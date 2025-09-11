import SwiftUI

struct PlanSpec: View {
    private let spec: LocalizedStringKey
    private let icon, value: String
    
    init(_ spec: LocalizedStringKey, icon: String, value: String) {
        self.spec = spec
        self.icon = icon
        self.value = value
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .title3()
            
            VStack(alignment: .leading, spacing: 0) {
                Text(spec)
                    .footnote()
                    .secondary()
                    .lineLimit(1)
                
                Text(value)
            }
            .semibold()
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
        .padding(1)
        .background(.indigo, in: .rect(cornerRadius: 9))
    }
}

#Preview {
    PlanSpec("CPU", icon: "hammer", value: "16")
}
