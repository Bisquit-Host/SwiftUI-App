import SwiftUI
import SafariCover

struct FTBModpackModsSheetView: View {
    private let mods: [FTBModpackVersionMod]
    private let isLoading: Bool
    
    init(
        mods: [FTBModpackVersionMod],
        isLoading: Bool
    ) {
        self.mods = mods
        self.isLoading = isLoading
    }
    
    @State private var metadataByModId: [String: FTBModpackVersionModMetadata] = [:]
    @State private var requestedMetadataModIds = Set<String>()
    @State private var showSafari = false
    @State private var safariURL = ""
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading mod list")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if mods.isEmpty {
                ContentUnavailableView(
                    "No mods found",
                    systemImage: "shippingbox"
                )
            } else {
                List(mods, id: \.id) { mod in
                    FTBModpackModRowView(
                        mod: mod,
                        metadata: metadataByModId[mod.id],
                        openLink: openLinkInSafari
                    )
                    .task {
                        await fetchMetadataIfNeeded(for: mod)
                    }
                }
            }
        }
        .navigationTitle("Mod list")
        .navigationBarTitleDisplayMode(.inline)
        .safariCover($showSafari, url: safariURL)
    }
    
    private func fetchMetadataIfNeeded(for mod: FTBModpackVersionMod) async {
        guard requestedMetadataModIds.insert(mod.id).inserted else {
            return
        }
        
        guard let metadata = await FTBModpackVersionModMetadataService.shared.fetchMetadata(for: mod) else {
            return
        }
        
        metadataByModId[mod.id] = metadata
    }
    
    private func openLinkInSafari(_ link: String) {
        guard URL(string: link) != nil else {
            return
        }
        
        safariURL = link
        showSafari = true
    }
}
