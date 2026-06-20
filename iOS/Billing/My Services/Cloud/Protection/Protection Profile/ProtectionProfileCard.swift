import SwiftUI
import BisquitoNet

struct ProtectionProfileCard: View {
    @Environment(VDSProtectionVM.self) private var vm
    
    private let profile: VDSProtectionProfile
    
    init(_ profile: VDSProtectionProfile) {
        self.profile = profile
    }
    
    @State private var showDeleteDialog = false
    
    private var presetName: String {
        presetName(for: profile)
    }
    
    var body: some View {
        if vm.isSelectingProfiles {
            cardContent
                .contentShape(.rect)
                .onTapGesture {
                    vm.toggleProfileSelection(profile.id)
                }
        } else {
            cardContent
        }
    }
    
    private func deleteProfile() {
        Task {
            await vm.deleteProfile(profile.id)
        }
    }
    
    private var cardContent: some View {
        let isSelected = vm.selectedProfileIds.contains(profile.id)
        
        return HStack(spacing: 10) {
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
            
            if vm.isSelectingProfiles {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .title3()
                    .foregroundStyle(isSelected ? .green : .secondary)
            } else {
                Menu {
                    NavigationLink {
                        ProtectionProfileEditor(.edit(profile))
                            .environment(vm)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        showDeleteDialog = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(5)
                }
                .tint(.primary)
                .buttonBorderShape(.circle)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
        .alert("Delete profile?", isPresented: $showDeleteDialog) {
            Button("Delete", role: .destructive, action: deleteProfile)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(presetName(for: profile))
        }
    }
    
    private func presetName(for profile: VDSProtectionProfile) -> String {
        if let name = profile.presetName, !name.isEmpty {
            return name
        }
        
        if let preset = vm.presets.first(where: { $0.id == profile.presetId }) {
            return preset.name
        }
        
        return "Preset #\(profile.presetId)"
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

//#Preview {
//    ProtectionProfileCard(
//        VDSProtectionProfile(
//            id: 1,
//            presetId: 10,
//            presetName: "FiveM TCP",
//            protocol: .tcp,
//            minDstPort: 30120,
//            maxDstPort: 30150,
//            autoCreated: false,
//            notes: "Game ports"
//        )
//    )
//    .darkSchemePreferred()
//}
