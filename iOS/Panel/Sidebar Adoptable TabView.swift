import SwiftUI

struct SidebarAdoptableTabView: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18, macOS 15, tvOS 18, visionOS 2, *) {
            content
                .tabViewStyle(.sidebarAdaptable)
        } else {
            content
        }
    }
}

extension View {
    func sidebarAdaptableStyle() -> some View {
        self.modifier(SidebarAdoptableTabView())
    }
}
