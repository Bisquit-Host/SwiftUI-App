import ScrechKit
import Calagopus

struct PanelSidebarHeader: View {
    let server: CalagopusServer?
    let servers: [CalagopusServer]
    let onSwitchServer: (CalagopusServer) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Menu {
                ForEach(servers) { candidate in
                    Button(candidate.name, systemImage: systemImage(for: candidate)) {
                        onSwitchServer(candidate)
                    }
                    .disabled(candidate.id == server?.id || candidate.isSuspended)
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Text(server?.name ?? String(localized: "Server"))
                        .title(.semibold)
                        .lineLimit(2)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .caption(.semibold)
                        .secondary()
                        .imageScale(.small)
                }
                .foregroundStyle(.primary)
                .contentShape(.rect)
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .disabled(servers.filter { !$0.isSuspended }.count <= 1)
            
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
    
    private func systemImage(for server: CalagopusServer) -> String {
        if server.id == self.server?.id {
            return "checkmark"
        }
        
        if server.isSuspended {
            return "lock"
        }
        
        return "externaldrive"
    }
}

#Preview {
    PanelSidebarHeader(server: PreviewProp.serverAttributes, servers: [PreviewProp.serverAttributes]) { _ in }
        .padding()
        .darkSchemePreferred()
}
