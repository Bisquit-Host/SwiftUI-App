import ScrechKit

enum ModelLevel: Int, CaseIterable {
    case light, medium, high, xhigh

    init(reasoningEffort: String) {
        switch reasoningEffort {
        case "light": self = .light
        case "high": self = .high
        case "xhigh": self = .xhigh
        default: self = .medium
        }
    }

    var title: String {
        switch self {
        case .light: "Light"
        case .medium: "Medium"
        case .high: "High"
        case .xhigh: "XHigh"
        }
    }

    var reasoningEffort: String {
        switch self {
        case .light: "light"
        case .medium: "medium"
        case .high: "high"
        case .xhigh: "xhigh"
        }
    }
}
