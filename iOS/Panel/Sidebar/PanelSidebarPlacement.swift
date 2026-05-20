enum PanelSidebarPlacement: String, CaseIterable {
    case left, right
    
    var title: String {
        switch self {
        case .left: "Left"
        case .right: "Right"
        }
    }
    
    var icon: String {
        switch self {
        case .left: "sidebar.left"
        case .right: "sidebar.right"
        }
    }
}
