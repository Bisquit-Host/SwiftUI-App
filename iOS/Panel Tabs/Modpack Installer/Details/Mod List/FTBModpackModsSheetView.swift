import SwiftUI
import Calagopus
import SafariCover

struct FTBModpackModsSheetView: View {
    let mods: [FTBModpackVersionMod]
    let isLoading: Bool
    
    @State private var metadataByModId: [String: FTBModpackVersionModMetadata] = [:]
    @State private var loadingMetadataTaskID: String?
    @State private var showSafari = false
    @State private var url = ""
    
    var body: some View {
        Group {
            if isLoading || loadingMetadataTaskID == metadataTaskID {
                ProgressView("Loading mod list")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if mods.isEmpty {
                ContentUnavailableView("No mods found", systemImage: "shippingbox")
                
            } else {
                List(mods) {
                    FTBModpackModRowView(
                        mod: $0,
                        metadata: metadataByModId[$0.id],
                        openLink: openLinkInSafari
                    )
                }
            }
        }
        .navigationTitle("Mod list")
        .navigationBarTitleDisplayMode(.inline)
        .safariCover($showSafari, url: url)
        .task(id: metadataTaskID) {
            await fetchAllMetadata()
        }
    }
    
    private var metadataTaskID: String {
        mods.map(\.id).joined(separator: "|")
    }
    
    private func fetchAllMetadata() async {
        let currentTaskID = metadataTaskID
        
        guard isLoading == false else {
            return
        }
        
        guard mods.isEmpty == false else {
            metadataByModId = [:]
            return
        }
        
        loadingMetadataTaskID = currentTaskID
        defer {
            if loadingMetadataTaskID == currentTaskID {
                loadingMetadataTaskID = nil
            }
        }
        
        let metadata = await FTBModpackVersionModMetadataService.shared.fetchMetadata(for: mods)
        guard Task.isCancelled == false else {
            return
        }
        
        metadataByModId = metadata
    }
    
    private func openLinkInSafari(_ link: String) {
        guard URL(string: link) != nil else { return }
        url = link
        showSafari = true
    }
}
