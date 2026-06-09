import ScrechKit

struct DashboardCardLabel: View {
    private let title: LocalizedStringKey
    private let description: LocalizedStringKey?
    private let icon: String
    private let tint: Color
    
    init(_ title: LocalizedStringKey, description: LocalizedStringKey? = nil, icon: String, tint: Color) {
        self.title = title
        self.description = description
        self.icon = icon
        self.tint = tint
    }
    
    var body: some View {
        HStack(spacing: 12) {
            BigGlassyIcon(icon, tint: tint)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .subheadline(.semibold)
                
                if let description {
                    Text(description)
                        .footnote()
                        .secondary()
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.forward")
                .secondary()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
