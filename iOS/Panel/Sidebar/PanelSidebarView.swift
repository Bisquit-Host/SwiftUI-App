import ScrechKit

struct PanelSidebarView: View {
    private let edgeSwipeWidth: CGFloat = 24
    
    @State private var customizationVM = PanelSidebarCustomizationVM()
    @State private var selectedTab: Tabs = .info
    @State private var sheetCustomization = false
    @State private var offset = 0.0
    @State private var lastDragOffset = 0.0
    @State private var progress = 0.0
    @State private var panGesture: UIPanGestureRecognizer?
    @State private var tabSwitchTask: Task<Void, Never>?
    
    @AppStorage("panel_sidebar_selected_tab") private var selectedTabRawValue = Tabs.info.rawValue
    
    var body: some View {
        PanelAdaptiveView { _, isLandscape in
            let sideBarWidth: CGFloat = isLandscape ? 220 : 250
            let isSidebarOnRight = customizationVM.placement == .right
            let sidebarBaseOffset = isSidebarOnRight ? sideBarWidth : -sideBarWidth
            let sidebarOffset = isSidebarOnRight ? -offset : offset
            let contentOffset = isSidebarOnRight ? -offset : offset
            
            let layout = isLandscape
                ? AnyLayout(HStackLayout(spacing: 0))
                : AnyLayout(ZStackLayout(alignment: isSidebarOnRight ? .trailing : .leading))
            
            layout {
                if isLandscape && isSidebarOnRight {
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
                            .opacity(isLandscape ? 0 : progress)
                    }
                    .offset(x: isLandscape ? 0 : contentOffset)
                }
                
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
                .offset(x: isLandscape ? 0 : sidebarBaseOffset)
                .offset(x: isLandscape ? 0 : sidebarOffset)
                .environment(customizationVM)
                .sheet($sheetCustomization) {
                    NavigationStack {
                        PanelSidebarCustomizationSheet()
                            .environment(customizationVM)
                    }
                }
                
                if !isLandscape || !isSidebarOnRight {
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
                            .opacity(isLandscape ? 0 : progress)
                    }
                    .offset(x: isLandscape ? 0 : contentOffset)
                }
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
                    let directionMultiplier: CGFloat = isSidebarOnRight ? -1 : 1
                    let translation = (translationX * directionMultiplier) + lastDragOffset
                    let velocity = (velocityX * directionMultiplier) / 3
                    
                    if state == .began || state == .changed {
                        offset = max(min(translation, sideBarWidth), 0)
                        progress = max(min(offset / sideBarWidth, 1), 0)
                    } else {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            if (velocity + offset) > (sideBarWidth * 0.5) {
                                offset = sideBarWidth
                                progress = 1
                            } else {
                                offset = 0
                                progress = 0
                            }
                        }
                        
                        lastDragOffset = offset
                    }
                } shouldBegin: { gesture in
                    if isLandscape { return false }
                    
                    let startX = gesture.location(in: gesture.view).x
                    let viewWidth = gesture.view?.bounds.width ?? 0
                    
                    let isEdgeSwipe = isSidebarOnRight
                        ? startX >= (viewWidth - edgeSwipeWidth)
                        : startX <= edgeSwipeWidth
                    
                    return !(isEdgeSwipe && offset == 0)
                }
            )
            .onChange(of: isLandscape) { _, newValue in
                panGesture?.isEnabled = !newValue
            }
            .onChange(of: customizationVM.tabVisibility) {
                ensureSelectedTabIsVisible()
            }
            .onChange(of: customizationVM.placement) {
                toggleSidebar()
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
            progress = 0
            offset = 0
            lastDragOffset = 0
        }
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
    PanelSidebarView()
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environment(ConsoleVM(""))
        .environmentObject(FileTabVM(""))
}
