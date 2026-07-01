import SwiftUI
import Calagopus

struct InstalledModList: View {
    @Environment(ModInstallerVM.self) private var vm
    
    let canUpdate: (MinecraftInstalledProject) -> Bool
    let installUpdate: (MinecraftInstalledProject) -> Void
    
    var body: some View {
        ScrollView {
            if !vm.installedMods.isEmpty {
                ForEach(vm.installedMods) {
                    InstalledModCard($0, canUpdate: canUpdate, installModUpdate: installUpdate)
                }
            }
        }
        .navigationTitle("Installed Mods")
        .toolbarTitleDisplayMode(.inline)
        .scenePadding(.horizontal)
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundImage())
        .overlay {
            if vm.isLoadingInstalledMods && vm.installedMods.isEmpty {
                ProgressView()
            } else if vm.installedMods.isEmpty {
                ContentUnavailableView(
                    "No installed mods",
                    systemImage: "shippingbox.fill",
                    description: Text("Installed mods will appear here")
                )
            }
        }
    }
}

#Preview {
    InstalledModList(
        canUpdate: { _ in true },
        installUpdate: { _ in }
    )
    .darkSchemePreferred()
    .environment(ModInstallerVM(""))
    .environmentObject(ValueStore())
}
