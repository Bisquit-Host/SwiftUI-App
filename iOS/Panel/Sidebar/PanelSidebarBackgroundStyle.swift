import Foundation

enum PanelSidebarBackgroundStyle: String, CaseIterable, Identifiable {
    case glass, ultraThinMaterial, ultraThickMaterial
    
    static let defaultsKey = "panel.sidebar.backgroundStyle.v1"
    
    static var selectableCases: [PanelSidebarBackgroundStyle] {
#if os(visionOS)
        [.ultraThinMaterial, .ultraThickMaterial]
#else
        allCases
#endif
    }
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .glass: "Glass"
        case .ultraThinMaterial: "Ultra thin material"
        case .ultraThickMaterial: "Ultra thick material"
        }
    }
    
    var icon: String {
        switch self {
        case .glass: "sparkles.rectangle.stack"
        case .ultraThinMaterial: "square.stack.3d.forward.dottedline"
        case .ultraThickMaterial: "square.stack.3d.up.fill"
        }
    }
}
