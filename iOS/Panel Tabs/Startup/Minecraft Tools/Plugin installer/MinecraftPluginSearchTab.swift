import SwiftUI
import Kingfisher

struct MinecraftPluginSearchTab: View {
    @Environment(StartupVM.self) private var vm
    
    @Binding var selectedProvider: MinecraftPluginProvider
    @Binding var searchQuery: String
    @Binding var minecraftVersion: String
    @Binding var pluginLoader: String
    @Binding var page: Int
    @Binding var selectedPlugin: MinecraftCatalogProject?
    
    let reloadPlugins: () -> Void
    let movePage: (Int) -> Void
    let handlePolymartAction: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Search") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Provider", selection: $selectedProvider) {
                            ForEach(MinecraftPluginProvider.allCases) {
                                Text($0.name)
                                    .tag($0)
                            }
                        }
                        .tint(.primary)
                        
                        TextField("Search", text: $searchQuery)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.search)
                            .onSubmit {
                                reloadPlugins()
                            }
                        
                        TextField("Minecraft version (optional)", text: $minecraftVersion)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Plugin loader (optional)", text: $pluginLoader)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Find plugins", systemImage: "magnifyingglass", action: reloadPlugins)
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.isLoadingMinecraftPlugins)
                    }
                }
                
                if selectedProvider == .polymart {
                    BillingSectionCard("Polymart account") {
                        VStack(alignment: .leading, spacing: 12) {
                            if vm.isLoadingMinecraftPolymart {
                                HStack(spacing: 10) {
                                    ProgressView()
                                    
                                    Text("Loading account state")
                                        .secondary()
                                }
                            } else {
                                Text(vm.isMinecraftPolymartLinked ? "Connected" : "Not connected")
                                    .subheadline(.semibold)
                                
                                Button {
                                    handlePolymartAction()
                                } label: {
                                    Label(
                                        vm.isMinecraftPolymartLinked ? "Disconnect Polymart" : "Connect Polymart",
                                        systemImage: vm.isMinecraftPolymartLinked ? "link.badge.minus" : "link.badge.plus"
                                    )
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(vm.isMinecraftPolymartLinked ? .red : .blue)
                            }
                        }
                    }
                }
                
                BillingSectionCard("Results") {
                    if vm.isLoadingMinecraftPlugins {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Loading plugins")
                                .secondary()
                        }
                    } else if !vm.minecraftPluginManagerAvailable {
                        Text("Plugin manager is unavailable")
                            .secondary()
                    } else if vm.minecraftPlugins.isEmpty {
                        Text("No plugins found")
                            .secondary()
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(vm.minecraftPlugins) { plugin in
                                Button {
                                    selectedPlugin = plugin
                                } label: {
                                    HStack(spacing: 12) {
                                        KFImage(plugin.iconURL)
                                            .resizable()
                                            .placeholder {
                                                Image(systemName: "puzzlepiece.fill")
                                                    .secondary()
                                            }
                                            .scaledToFill()
                                            .frame(width: 28, height: 28)
                                            .clipShape(.rect(cornerRadius: 8))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(plugin.name)
                                                .subheadline(.semibold)
                                                .foregroundStyle(.foreground)
                                            
                                            Text(plugin.description)
                                                .caption()
                                                .secondary()
                                                .lineLimit(2)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .secondary()
                                            .footnote()
                                    }
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if vm.minecraftPluginsPagination.totalPages > 1 {
                                HStack {
                                    Text("Page \(vm.minecraftPluginsPagination.currentPage) of \(vm.minecraftPluginsPagination.totalPages)")
                                        .footnote()
                                        .secondary()
                                    
                                    Spacer()
                                    
                                    Button("Previous") {
                                        movePage(-1)
                                    }
                                    .disabled(page <= 1 || vm.isLoadingMinecraftPlugins)
                                    
                                    Button("Next") {
                                        movePage(1)
                                    }
                                    .disabled(page >= vm.minecraftPluginsPagination.totalPages || vm.isLoadingMinecraftPlugins)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.never)
    }
}

#Preview {
    MinecraftPluginSearchTab(
        selectedProvider: .constant(.modrinth),
        searchQuery: .constant(""),
        minecraftVersion: .constant(""),
        pluginLoader: .constant(""),
        page: .constant(1),
        selectedPlugin: .constant(nil),
        reloadPlugins: {},
        movePage: { _ in },
        handlePolymartAction: {}
    )
    .darkSchemePreferred()
    .environment(StartupVM(""))
}
