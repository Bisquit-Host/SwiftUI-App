import ScrechKit

struct PanelSidebarView: View {
    private let edgeSwipeWidth: CGFloat = 24
    
    @State private var customizationVM = PanelSidebarCustomizationVM()
    @State private var sheetCustomization = false
    @State private var offset = 0.0
    @State private var lastDragOffset = 0.0
    @State private var panGesture: UIPanGestureRecognizer?
    @State private var tabSwitchTask: Task<Void, Never>?
    
    @Binding var selectedTab: Tabs
    @Binding var sidebarProgress: Double
    
    @AppStorage("panel_sidebar_selected_tab") private var selectedTabRawValue = Tabs.info.rawValue
    
    var body: some View {
        PanelAdaptiveView { _, isLandscape in
            let sideBarWidth: CGFloat = isLandscape ? 220 : 250
            
            let layout = isLandscape
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(ZStackLayout(alignment: .leading))
            
            layout {
                PanelSidebarList(selectedTab: $selectedTab) { tab in
                    toggleSidebar()
                    
                    tabSwitchTask?.cancel()
                    
                    if selectedTab == tab { return }
                    
                    tabSwitchTask = Task {
                        guard !Task.isCancelled else { return }
                        
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedTab = tab
                        }
                    }
                } onCustomize: {
                    sheetCustomization = true
                }
                .frame(width: sideBarWidth)
                .background(.thickMaterial)
                .offset(x: isLandscape ? 0 : -sideBarWidth)
                .offset(x: isLandscape ? 0 : offset)
                .environment(customizationVM)
                .sheet($sheetCustomization) {
                    NavigationStack {
                        PanelSidebarCustomizationSheet()
                            .environment(customizationVM)
                    }
                }
                
                ZStack {
                    BackgroundImage()
                        .ignoresSafeArea()
                    
                    PanelViewTabView(selectedTab: selectedTab)
                        .id(selectedTab)
                        .transition(.opacity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
                .overlay {
                    Rectangle()
                        .fill(.black.opacity(0.25))
                        .ignoresSafeArea()
                        .opacity(isLandscape ? 0 : sidebarProgress)
                }
                .offset(x: isLandscape ? 0 : offset)
            }
            .animation(.easeInOut(duration: 0.5), value: selectedTab)
            .gesture(
                PanelCustomGesture { gesture in
                    if panGesture == nil {
                        panGesture = gesture
                    }
                    
                    let state = gesture.state
                    let translationX = gesture.translation(in: gesture.view).x
                    let velocityX = gesture.velocity(in: gesture.view).x
                    let translation = translationX + lastDragOffset
                    let velocity = velocityX / 3
                    
                    if state == .began || state == .changed {
                        let nextOffset = max(min(translation, sideBarWidth), 0)
                        
                        if offset == 0 && nextOffset > 0 {
                            dismissTextFields()
                        }
                        
                        offset = nextOffset
                        sidebarProgress = max(min(offset / sideBarWidth, 1), 0)
                    } else {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            if (velocity + offset) > (sideBarWidth * 0.5) {
                                offset = sideBarWidth
                                sidebarProgress = 1
                            } else {
                                offset = 0
                                sidebarProgress = 0
                            }
                        }
                        
                        lastDragOffset = offset
                    }
                } shouldBegin: { gesture in
                    if isLandscape { return false }
                    
                    let velocity = gesture.velocity(in: gesture.view)
                    guard abs(velocity.x) > abs(velocity.y) else { return false }
                    
                    if offset > 0 {
                        return velocity.x < 0
                    }
                    
                    let startX = gesture.location(in: gesture.view).x
                    return startX > edgeSwipeWidth && velocity.x > 0
                }
            )
            .onChange(of: isLandscape) { _, newValue in
                panGesture?.isEnabled = !newValue
            }
            .onChange(of: customizationVM.tabVisibility) {
                ensureSelectedTabIsVisible()
            }
            .onChange(of: selectedTab) { _, newTab in
                selectedTabRawValue = newTab.rawValue
            }
            .onAppear {
                restoreSelectedTab()
                ensureSelectedTabIsVisible(animated: false)
            }
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
    
    private func toggleSidebar() {
        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
            sidebarProgress = 0
            offset = 0
            lastDragOffset = 0
        }
    }
    
    private func dismissTextFields() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func ensureSelectedTabIsVisible(animated: Bool = true) {
        guard !customizationVM.isTabVisible(selectedTab) else {
            return
        }
        
        guard let fallbackTab = customizationVM.firstVisibleTab else {
            return
        }
        
        if animated {
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedTab = fallbackTab
            }
        } else {
            selectedTab = fallbackTab
        }
    }
    
    private func restoreSelectedTab() {
        guard let restoredTab = Tabs(rawValue: selectedTabRawValue) else {
            selectedTab = .info
            return
        }
        
        selectedTab = restoredTab
    }
    
    private func selectPreviousTab() {
        selectVisibleTab(offset: -1)
    }
    
    private func selectNextTab() {
        selectVisibleTab(offset: 1)
    }
    
    private func selectVisibleTab(offset: Int) {
        let visibleTabs = customizationVM.visibleSections.flatMap(\.tabs)
        
        guard !visibleTabs.isEmpty else {
            return
        }
        
        guard let currentIndex = visibleTabs.firstIndex(of: selectedTab) else {
            selectedTab = visibleTabs[0]
            return
        }
        
        let count = visibleTabs.count
        let nextIndex = (currentIndex + offset + count) % count
        
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedTab = visibleTabs[nextIndex]
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
}
