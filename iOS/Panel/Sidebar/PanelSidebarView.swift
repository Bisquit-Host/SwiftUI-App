import ScrechKit

struct PanelSidebarView: View {
    private let edgeSwipeWidth: CGFloat = 24

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @EnvironmentObject private var store: ValueStore

    @State private var offset = 0.0
    @State private var lastDragOffset = 0.0
    @State private var panGesture: UIPanGestureRecognizer?
    @State private var tabSwitchTask: Task<Void, Never>?

    @Binding var selectedTab: Tabs
    @Binding var sidebarProgress: Double

    @AppStorage("panel_sidebar_selected_tab") private var selectedTabRawValue = Tabs.info.rawValue

    var body: some View {
        // The tab content is the base layer, the sidebar is layered on top and never drives the navigation bar
        PanelViewTabView(selectedTab: selectedTab)
            .environment(\.panelHasPersistentSidebar, isPersistent)
            .id(selectedTab)
            .transition(.opacity)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            .accessibilityHidden(!isPersistent && sidebarProgress > 0)
            .safeAreaInset(edge: .leading, spacing: 0) {
                if isPersistent {
                    PanelSidebarPane(selectedTab: $selectedTab, width: sidebarWidth, onSelect: select)
                }
            }
            .overlay(alignment: .leading) {
                if !isPersistent {
                    PanelSidebarDrawer(
                        selectedTab: $selectedTab,
                        width: sidebarWidth,
                        offset: offset,
                        progress: sidebarProgress,
                        onSelect: select,
                        onClose: closeSidebar
                    )
                }
            }
            .toolbar {
                if !isPersistent {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(sidebarProgress > 0 ? "Close sidebar" : "Open sidebar", systemImage: "sidebar.left", action: toggleSidebar)
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: selectedTab)
            .gesture(PanelCustomGesture(handle: handleDrag, shouldBegin: shouldBeginDrag))
            .onChange(of: isPersistent) { _, newValue in
                panGesture?.isEnabled = !newValue
                sidebarProgress = 0
                offset = 0
                lastDragOffset = 0
            }
            .onChange(of: selectedTab) { _, newTab in
                selectedTabRawValue = newTab.rawValue
            }
            .onAppear {
                restoreSelectedTab()
            }
            .background {
                Button(action: selectPreviousTab) {
                    EmptyView()
                }
                .keyboardShortcut(.upArrow, modifiers: [.option])
                .frame(0)
                .opacity(0)
                .accessibilityHidden(true)

                Button(action: selectNextTab) {
                    EmptyView()
                }
                .keyboardShortcut(.downArrow, modifiers: [.option])
                .frame(0)
                .opacity(0)
                .accessibilityHidden(true)
            }
            .onDisappear {
                tabSwitchTask?.cancel()
            }
    }

    private var isPersistent: Bool {
        if horizontalSizeClass == .compact {
            verticalSizeClass == .compact
        } else {
            horizontalSizeClass == .regular
        }
    }

    private var sidebarWidth: Double {
        isPersistent ? 220 : 250
    }

    private var sidebarAnimation: Animation? {
        reduceMotion || !store.bigAssAnimations
        ? nil
        : .snappy(duration: 0.25, extraBounce: 0)
    }

    private func select(_ tab: Tabs) {
        closeSidebar()

        tabSwitchTask?.cancel()

        guard selectedTab != tab else {
            return
        }

        tabSwitchTask = Task {
            guard !Task.isCancelled else {
                return
            }

            withAnimation(.easeInOut(duration: 0.5)) {
                selectedTab = tab
            }
        }
    }

    private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        if panGesture == nil {
            panGesture = gesture
        }

        let translation = gesture.translation(in: gesture.view).x + lastDragOffset
        let velocity = gesture.velocity(in: gesture.view).x / 3

        switch gesture.state {
        case .began, .changed:
            let nextOffset = max(min(translation, sidebarWidth), 0)

            if offset == 0 && nextOffset > 0 {
                dismissTextFields()
            }

            offset = nextOffset
            sidebarProgress = offset / sidebarWidth

        default:
            withAnimation(sidebarAnimation) {
                if velocity + offset > sidebarWidth * 0.5 {
                    offset = sidebarWidth
                    sidebarProgress = 1
                } else {
                    offset = 0
                    sidebarProgress = 0
                }
            }

            lastDragOffset = offset
        }
    }

    private func shouldBeginDrag(_ gesture: UIPanGestureRecognizer) -> Bool {
        guard !isPersistent else {
            return false
        }

        let velocity = gesture.velocity(in: gesture.view)

        guard abs(velocity.x) > abs(velocity.y) else {
            return false
        }

        if offset > 0 {
            return velocity.x < 0
        }

        let startX = gesture.location(in: gesture.view).x
        return startX > edgeSwipeWidth && velocity.x > 0
    }

    private func toggleSidebar() {
        guard offset == 0 else {
            closeSidebar()
            return
        }

        dismissTextFields()

        withAnimation(sidebarAnimation) {
            sidebarProgress = 1
            offset = sidebarWidth
            lastDragOffset = sidebarWidth
        }
    }

    private func closeSidebar() {
        withAnimation(sidebarAnimation) {
            sidebarProgress = 0
            offset = 0
            lastDragOffset = 0
        }
    }

    private func dismissTextFields() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func restoreSelectedTab() {
        guard let restoredTab = Tabs(rawValue: selectedTabRawValue) else {
            selectedTab = .info
            return
        }

        selectedTab = restoredTab
    }

    private func selectPreviousTab() {
        selectTab(offset: -1)
    }

    private func selectNextTab() {
        selectTab(offset: 1)
    }

    private func selectTab(offset: Int) {
        let tabs = PanelSidebarSection.all.flatMap(\.tabs)

        guard !tabs.isEmpty else {
            return
        }

        guard let currentIndex = tabs.firstIndex(of: selectedTab) else {
            selectedTab = tabs[0]
            return
        }

        let count = tabs.count
        let nextIndex = (currentIndex + offset + count) % count

        withAnimation(.easeInOut(duration: 0.25)) {
            selectedTab = tabs[nextIndex]
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: Tabs = .info
    @Previewable @State var sidebarProgress = 0.0

    PanelSidebarView(
        selectedTab: $selectedTab,
        sidebarProgress: $sidebarProgress
    )
    .darkSchemePreferred()
    .environment(PanelVM(""))
    .environment(ConsoleVM(""))
    .environmentObject(FileTabVM(""))
    .environmentObject(ValueStore())
}
