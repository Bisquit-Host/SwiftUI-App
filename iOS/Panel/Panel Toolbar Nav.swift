import SwiftUI

struct PanelToolbarNav: View {
    @Binding private var isExpanded: Bool
    
    init(_ isExpanded: Binding<Bool>) {
        _isExpanded = isExpanded
    }
    
    var body: some View {
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
                    PanelToolbarNavCard("Info", icon: "info.circle", tab: .info) {
                        dismiss()
                    }
                    
                    PanelToolbarNavCard("Console", icon: "terminal", tab: .console) {
                        dismiss()
                    }
                    
                    PanelToolbarNavCard("Files", icon: "folder", tab: .files) {
                        dismiss()
                    }
                    
                    PanelToolbarNavCard("Backups", icon: "externaldrive.badge.icloud", tab: .backup) {
                        dismiss()
                    }
                    
                    PanelToolbarNavCard("Startup", icon: "play.circle", tab: .startup) {
                        dismiss()
                    }
                    
                    PanelToolbarNavCard("Subdomains", icon: "globe", tab: .subdomain) {
                        dismiss()
                    }
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
    }
    
    private func dismiss() {
        isExpanded = false
    }
}

struct PanelToolbarNavCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let title: LocalizedStringKey
    private let icon: String
    private let tab: Tabs
    private let completion: () -> Void
    
    init(_ title: LocalizedStringKey, icon: String, tab: Tabs, completion: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.tab = tab
        self.completion = completion
    }
    
    var body: some View {
        Button {
            store.lastTabPanel = tab
            completion()
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
        PanelToolbarNav(.constant(true))
    }
    .environmentObject(ValueStore())
}
