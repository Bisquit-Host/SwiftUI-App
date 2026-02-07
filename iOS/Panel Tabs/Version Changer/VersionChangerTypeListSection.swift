import SwiftUI

struct VersionChangerTypeListSection: View {
    @Environment(VersionChangerVM.self) private var vm
    
    var body: some View {
        if !vm.versionChangerAvailable {
            Text("Types are unavailable")
                .secondary()
            
        } else if vm.versionChangerTypes.isEmpty {
            Text("No version types were returned by the panel")
                .secondary()
            
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(vm.versionChangerTypes.enumerated()), id: \.offset) { _, type in
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
            }
        }
    }
}

#Preview {
    VersionChangerTypeListSection()
        .darkSchemePreferred()
        .environment(VersionChangerVM(""))
}
