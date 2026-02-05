import SwiftUI

struct VersionChangerTypeListSection: View {
    @Environment(StartupVM.self) private var vm
    
    var body: some View {
        if vm.isLoadingVersionChanger {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading available types")
                    .secondary()
            }
        } else if !vm.versionChangerAvailable {
            Text("Types are unavailable")
                .secondary()
        } else if vm.versionChangerTypes.isEmpty {
            Text("No version types were returned by the panel")
                .secondary()
        } else {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(vm.versionChangerTypes) { type in
                    NavigationLink {
                        VersionChangerVersionListView(type: type)
                    } label: {
                        HStack(spacing: 12) {
                            VersionChangerTypeLogo(url: type.iconURL)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.name)
                                    .subheadline(.semibold)
                                
                                Text("\(type.builds) builds")
                                    .secondary()
                                    .footnote()
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .secondary()
                                .footnote()
                        }
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
        .environment(StartupVM(""))
}
