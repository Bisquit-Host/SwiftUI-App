import SwiftUI
import SafariCover

struct ModrinthProjectLinksSection: View {
    @EnvironmentObject private var store: ValueStore
    
    let project: MinecraftCatalogProject
    let isEnabled: Bool
    
    @State private var links: [ModrinthProjectLink] = []
    @State private var isLoading = false
    @State private var showSafari = false
    @State private var selectedURL = ""
    
    var body: some View {
        if isEnabled {
            BillingSectionCard("Links", showsBackground: false) {
                VStack(alignment: .leading, spacing: 10) {
                    if isLoading {
                        HStack(spacing: 10) {
                            ProgressView()
                            
                            Text("Loading links")
                                .secondary()
                        }
                    } else if links.isEmpty {
                        Text("No links available")
                            .secondary()
                    } else {
                        ForEach(links) { link in
                            Button {
                                selectedURL = link.url
                                showSafari = true
                            } label: {
                                HStack(spacing: 10) {
                                    Label(link.title, systemImage: link.systemImage)
                                        .subheadline()
                                        .foregroundStyle(.foreground)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "link")
                                        .secondary()
                                        .footnote()
                                }
                                .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                            .minecraftProjectContextMenu(webPageURL: link.url)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
            .safariCover($showSafari, url: selectedURL)
            .task(id: project.id) {
                await loadLinks()
            }
        }
    }
    
    private func loadLinks() async {
        guard isEnabled else {
            return
        }
        
        isLoading = true
        links = await ModrinthProjectLinksService.shared.fetchLinks(for: project)
        isLoading = false
    }
}
