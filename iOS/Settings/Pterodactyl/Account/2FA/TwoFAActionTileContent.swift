import ScrechKit

struct TwoFAActionTileContent: View {
    private let title: LocalizedStringKey
    private let icon: String
    
    init(_ title: LocalizedStringKey, icon: String) {
        self.title = title
        self.icon = icon
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .title(.semibold)
                .foregroundStyle(.white)
                .frame(46)
                .background(.blue.gradient, in: .rect(cornerRadius: 12))
            
            Text(title)
                .semibold()
            
            Spacer(minLength: 0)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }
}
