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
                                    linkLabel(for: link)
                                    
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
        guard isEnabled else { return }
        
        isLoading = true
        links = await ModrinthProjectLinksService.shared.fetchLinks(for: project)
        isLoading = false
    }
    
    @ViewBuilder
    private func linkLabel(for link: ModrinthProjectLink) -> some View {
        if isPatreonURL(link.url) {
            HStack(spacing: 6) {
                brandedIcon(.patreon)
                
                Text(link.title)
            }
            .subheadline()
            .foregroundStyle(.foreground)
            
        } else if link.title == "Discord" {
            HStack(spacing: 6) {
                brandedIcon(.discord)
                
                Text(link.title)
            }
            .subheadline()
            .foregroundStyle(.foreground)
            
        } else if shouldUseGitHubIcon(for: link), isGitHubURL(link.url) {
            HStack(spacing: 6) {
                brandedIcon(.gitHub)
                
                Text(link.title)
            }
            .subheadline()
            .foregroundStyle(.foreground)
            
        } else {
            Label(link.title, systemImage: link.systemImage)
                .subheadline()
                .foregroundStyle(.foreground)
        }
    }
    
    private func isPatreonURL(_ rawURL: String) -> Bool {
        guard let host = URL(string: rawURL)?.host?.lowercased() else {
            return false
        }
        
        return host.contains("patreon.com")
    }
    
    private func isGitHubURL(_ rawURL: String) -> Bool {
        guard let host = URL(string: rawURL)?.host?.lowercased() else {
            return false
        }
        
        return host == "github.com" || host.hasSuffix(".github.com")
    }
    
    private func shouldUseGitHubIcon(for link: ModrinthProjectLink) -> Bool {
        switch link.title {
        case "Source code", "Issues": true
        default: false
        }
    }
    
    private func brandedIcon(_ image: ImageResource) -> some View {
        Image(image)
            .resizable()
            .frame(16)
            .clipShape(.rect(cornerRadius: 5))
    }
}
