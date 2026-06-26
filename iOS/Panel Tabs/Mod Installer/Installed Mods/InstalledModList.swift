import SwiftUI
import Calagopus

struct InstalledModList: View {
    @Environment(ModInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    let canUpdate: (MinecraftInstalledProject) -> Bool
    let installModUpdate: (MinecraftInstalledProject) -> Void
    
    var body: some View {
        ScrollView {
            BillingSectionCard(showsBackground: false) {
                if vm.installedMods.isEmpty {
                    Text("No installed mods")
                        .secondary()
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(vm.installedMods) {
                            InstalledModCard($0, canUpdate: canUpdate, installModUpdate: installModUpdate)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
        }
        .padding()
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity)
        .background(BackgroundImage())
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
