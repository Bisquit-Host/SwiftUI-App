import ScrechKit

struct VDSProtectionProfileCard: View {
    let profile: CloudProtectionProfile
    let presetName: String
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(presetName)
                    .subheadline(.semibold)
                
                Text(detailsText)
                    .footnote()
                    .secondary()
                
                if let notes = profile.notes, !notes.isEmpty {
                    Text(notes)
                        .footnote()
                }
                
                if profile.autoCreated {
                    Text("Auto-created")
                        .caption()
                        .secondary()
                }
            }
            
            Spacer()
            
            Menu {
                Button("Edit", systemImage: "pencil") {
                    onEdit()
                }
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    onDelete()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .padding(5)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
    }
    
    private var detailsText: String {
        let minPort = profile.minDstPort ?? 1
        let maxPort = profile.maxDstPort ?? 65535
        let portText: String
        
        if minPort == 1 && maxPort == 65535 {
            portText = "All ports"
            
        } else if minPort == maxPort {
            portText = "Port \(minPort)"
            
        } else {
            portText = "\(minPort)–\(maxPort)"
        }
        
        let proto = profile.`protocol`.rawValue
        
        if profile.minDstPort != nil || profile.maxDstPort != nil {
            return "\(proto) • \(portText)"
        }
        
        return proto
    }
}

#Preview {
    VDSProtectionProfileCard(
        profile: .init(
            id: 1,
            presetId: 10,
            presetName: "FiveM TCP",
            protocol: .tcp,
            minDstPort: 30120,
            maxDstPort: 30150,
            autoCreated: false,
            notes: "Game ports"
        ),
        presetName: "FiveM TCP",
        onEdit: {},
        onDelete: {}
    )
    .padding()
    .darkSchemePreferred()
}
