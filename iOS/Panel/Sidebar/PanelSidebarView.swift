import ScrechKit

struct PanelSidebarView: View {
    private let edgeSwipeWidth: CGFloat = 24
    
    @State private var selectedTab: Tabs = .info
    @State private var offset: CGFloat = 0
    @State private var lastDragOffset: CGFloat = 0
    @State private var progress: CGFloat = 0
    @State private var panGesture: UIPanGestureRecognizer?
    @State private var tabSwitchTask: Task<Void, Never>?
    
    var body: some View {
        PanelAdaptiveView { _, isLandscape in
            let sideBarWidth: CGFloat = isLandscape ? 220 : 250
            let layout = isLandscape ? AnyLayout(HStackLayout(spacing: 0)) : AnyLayout(ZStackLayout(alignment: .leading))
            
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
                }
                .frame(width: sideBarWidth)
                .offset(x: isLandscape ? 0 : -sideBarWidth)
                .offset(x: isLandscape ? 0 : offset)
                
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
                    .offset(x: isLandscape ? 0 : offset)
            }
            .animation(.easeInOut(duration: 0.5), value: selectedTab)
            .gesture(
                PanelCustomGesture(
                    handle: { gesture in
                        if panGesture == nil {
                            panGesture = gesture
                        }
                        
                        let state = gesture.state
                        let translation = gesture.translation(in: gesture.view).x + lastDragOffset
                        let velocity = gesture.velocity(in: gesture.view).x / 3
                        
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
                    },
                    shouldBegin: { gesture in
                        if isLandscape {
                            return false
                        }
                        
                        let startX = gesture.location(in: gesture.view).x
                        let isLeadingEdgeSwipe = startX <= edgeSwipeWidth
                        return !(isLeadingEdgeSwipe && offset == 0)
                    }
                )
            )
            .onChange(of: isLandscape) { _, newValue in
                panGesture?.isEnabled = !newValue
            }
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
}

#Preview {
    PanelSidebarView()
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environment(ConsoleVM(""))
        .environmentObject(FileTabVM(""))
}
