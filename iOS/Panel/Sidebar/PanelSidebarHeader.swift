import ScrechKit
import Calagopus

struct PanelSidebarHeader: View {
    let server: CalagopusServer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(server?.name ?? String(localized: "Server"))
                .title(.semibold)
                .lineLimit(2)
            
            if let description = server?.description, !description.isEmpty {
                Text(description)
                    .caption()
                    .secondary()
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
    }
}

#Preview {
    PanelSidebarHeader(server: PreviewProp.serverAttributes)
        .padding()
        .darkSchemePreferred()
}
