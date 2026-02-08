import Foundation

enum PanelSidebarBackgroundStyle: String, CaseIterable, Identifiable {
    case ultraThinMaterial, ultraThickMaterial
    
    static let defaultsKey = "panel.sidebar.backgroundStyle.v1"
    
    static var selectableCases: [PanelSidebarBackgroundStyle] {
        allCases
    }
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .ultraThinMaterial:
            "Ultra thin material"
        case .ultraThickMaterial:
            "Ultra thick material"
        }
    }
    
    var icon: String {
        switch self {
        case .ultraThinMaterial:
            "square.stack.3d.forward.dottedline"
        case .ultraThickMaterial:
            "square.stack.3d.up.fill"
        }
    }
}
