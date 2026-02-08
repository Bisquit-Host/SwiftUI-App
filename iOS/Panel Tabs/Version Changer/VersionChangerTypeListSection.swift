import SwiftUI

struct VersionChangerTypeListSection: View {
    @Environment(VersionChangerVM.self) private var vm
    
    private let sectionDefinitions = [
        VersionChangerTypeSectionDefinition(
            title: "Recommended",
            identifiers: [
                "VANILLA",
                "PAPER",
                "FABRIC",
                "FORGE",
                "NEOFORGE",
                "VELOCITY"
            ]
        ),
        VersionChangerTypeSectionDefinition(
            title: "Established",
            identifiers: [
                "PURPUR",
                "PUFFERFISH",
                "FOLIA",
                "SPONGE",
                "SPIGOT",
                "BUNGEECORD",
                "WATERFALL"
            ]
        ),
        VersionChangerTypeSectionDefinition(
            title: "Experimental",
            identifiers: [
                "QUILT",
                "CANVAS"
            ]
        ),
        VersionChangerTypeSectionDefinition(
            title: "Miscellaneous",
            identifiers: [
                "VELOCITY_CTD",
                "ARCLIGHT",
                "MOHIST",
                "YOUER",
                "MAGMA",
                "DIVINEMC",
                "LEAF",
                "LEAVES",
                "ASPAPER",
                "LEGACYFABRIC",
                "PLUTO"
            ]
        ),
        VersionChangerTypeSectionDefinition(
            title: "Limbos",
            identifiers: [
                "LOOHPLIMBO",
                "NANOLIMBO"
            ]
        )
    ]
    
    var body: some View {
        if !vm.versionChangerAvailable {
            Text("Types are unavailable")
                .secondary()
            
        } else if vm.versionChangerTypes.isEmpty {
            Text("No version types were returned by the panel")
                .secondary()
            
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(sectionedTypes) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .headline(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(section.types) { type in
                                typeRow(type)
                            }
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(in: .rect(cornerRadius: 12))
                }
            }
        }
    }
    
    @ViewBuilder
    private func typeRow(_ type: VersionChangerProviderType) -> some View {
        NavigationLink {
            VersionChangerVersionListView(type: type)
                .environment(vm)
        } label: {
            HStack(spacing: 12) {
                VersionChangerTypeLogo(url: type.iconURL, size: 64)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.name)
                        .title3(.semibold)
                    
                    Text("\(type.builds) builds")
                        .secondary()
                        .footnote()
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .secondary()
                    .footnote()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
    
    private var sectionedTypes: [VersionChangerTypeSection] {
        let groupedTypes = Dictionary(grouping: vm.versionChangerTypes) { type in
            normalizedIdentifier(type.identifier)
        }
        
        var usedIdentifiers = Set<String>()
        var output: [VersionChangerTypeSection] = []
        
        for definition in sectionDefinitions {
            let types = definition.identifiers.flatMap { identifier in
                let normalized = normalizedIdentifier(identifier)
                
                guard let values = groupedTypes[normalized] else {
                    return [VersionChangerProviderType]()
                }
                
                usedIdentifiers.insert(normalized)
                return values
            }
            
            guard !types.isEmpty else {
                continue
            }
            
            output.append(VersionChangerTypeSection(title: definition.title, types: types))
        }
        
        let newTypes = vm.versionChangerTypes
            .filter { type in
                !usedIdentifiers.contains(normalizedIdentifier(type.identifier))
            }
            .sorted { left, right in
                left.name.localizedStandardCompare(right.name) == .orderedAscending
            }
        
        if !newTypes.isEmpty {
            output.append(VersionChangerTypeSection(title: "New", types: newTypes))
        }
        
        return output
    }
    
    private func normalizedIdentifier(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
    }
}

#Preview {
    VersionChangerTypeListSection()
        .darkSchemePreferred()
        .environment(VersionChangerVM(""))
}

private struct VersionChangerTypeSectionDefinition {
    let title: String
    let identifiers: [String]
}

private struct VersionChangerTypeSection: Identifiable {
    let title: String
    let types: [VersionChangerProviderType]
    
    var id: String {
        title
    }
}
