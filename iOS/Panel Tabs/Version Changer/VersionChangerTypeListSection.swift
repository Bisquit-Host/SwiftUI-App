import SwiftUI

struct VersionChangerTypeListSection: View {
    @Environment(VersionChangerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
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
                    .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 12))
                }
            }
        }
    }
    
    @ViewBuilder
    private func typeRow(_ type: VersionChangerProviderType) -> some View {
        NavigationLink {
            VersionChangerVersionListView(type)
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
        let orderedCategories = vm.versionChangerTypes
            .map { normalizedCategory($0.category) }
            .reduce(into: [String]()) { result, category in
                if result.contains(category) == false {
                    result.append(category)
                }
            }

        return orderedCategories.compactMap { category in
            let rawTypes = vm.versionChangerTypes.filter { type in
                normalizedCategory(type.category) == category
            }

            guard rawTypes.isEmpty == false else {
                return nil
            }

            return VersionChangerTypeSection(title: category, types: rawTypes)
        }
    }

    private func normalizedCategory(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.isEmpty == false else {
            return "Other"
        }

        return trimmed
    }
}

#Preview {
    VersionChangerTypeListSection()
        .darkSchemePreferred()
        .environment(VersionChangerVM(""))
}

private struct VersionChangerTypeSection: Identifiable {
    let title: String
    let types: [VersionChangerProviderType]
    
    var id: String {
        title
    }
}
