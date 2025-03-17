import SwiftUI

struct PanelToolbarNav: View {
    @State private var isExpanded = true
    
    var body: some View {
        if isExpanded {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button {
                        
                    } label: {
                        Image(.defaultIcon)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(.circle)
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(.defaultIcon)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(.circle)
                    }
                    
                    Button {
                        
                    } label: {
                        Image(.defaultIcon)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(.circle)
                    }
                }
                
                ScrollView {
                    VStack(alignment: .leading) {
                        PanelToolbarNavCard("Info", icon: "info.circle", tab: .info)
                        PanelToolbarNavCard("Console", icon: "terminal", tab: .console)
                        PanelToolbarNavCard("Files", icon: "folder", tab: .files)
                        PanelToolbarNavCard("Backups", icon: "externaldrive.badge.icloud", tab: .backup)
                        PanelToolbarNavCard("Startup", icon: "play.circle", tab: .startup)
                        PanelToolbarNavCard("Subdomains", icon: "globe", tab: .subdomain)
                    }
                }
                .scrollIndicators(.never)
                .frame(maxHeight: 300)
            }
            .frame(width: 200, height: 300)
            .padding([.top, .horizontal])
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.ultraThinMaterial, lineWidth: 1)
            }
        } else {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .footnote(.bold)
                    .frame(width: 35, height: 35)
                    .background(.ultraThinMaterial, in: .circle)
            }
            .foregroundStyle(.primary)
        }
    }
}

struct PanelToolbarNavCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let title: LocalizedStringKey
    private let icon: String
    private let tab: Tabs
    
    init(_ title: LocalizedStringKey, icon: String, tab: Tabs) {
        self.title = title
        self.icon = icon
        self.tab = tab
    }
    
    var body: some View {
        Button {
            store.lastTabPanel = tab
        } label: {
            Label {
                Text(title)
                    .footnote(.bold)
            } icon: {
                Image(systemName: icon)
                    .resizable()
                    .symbolVariant(.fill)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial, in: .circle)
            }
        }
        .foregroundStyle(.foreground)
        .frame(width: 200, alignment: .leading)
        .padding(5)
        .selectedBackground(store.lastTabPanel == tab)
    }
}

fileprivate struct BackgroundModifier: ViewModifier {
    private let isSelected: Bool
    
    init(_ isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    func body(content: Content) -> some View {
        if isSelected {
            content
                .background(.ultraThinMaterial, in: .capsule)
        } else {
            content
        }
    }
}

fileprivate extension View {
    func selectedBackground(_ isSelected: Bool) -> some View {
        modifier(BackgroundModifier(isSelected))
    }
}

#Preview {
    NavigationView {
        PanelToolbarNav()
    }
    .environmentObject(ValueStore())
}
