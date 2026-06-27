import SwiftUI
import Calagopus

struct InstalledModList: View {
    @Environment(ModInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    let canUpdate: (MinecraftInstalledProject) -> Bool
    let installModUpdate: (MinecraftInstalledProject) -> Void
    
    var body: some View {
        ScrollView {
            if !vm.installedMods.isEmpty {
                BillingSectionCard(showsBackground: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(vm.installedMods) {
                            InstalledModCard($0, canUpdate: canUpdate, installModUpdate: installModUpdate)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
            }
        }
        .navigationTitle("Installed Mods")
        .toolbarTitleDisplayMode(.inline)
        .scenePadding(.horizontal)
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundImage())
        .overlay {
            if vm.installedMods.isEmpty {
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
        installModUpdate: { _ in }
    )
    .darkSchemePreferred()
    .environment(ModInstallerVM(""))
    .environmentObject(ValueStore())
}
