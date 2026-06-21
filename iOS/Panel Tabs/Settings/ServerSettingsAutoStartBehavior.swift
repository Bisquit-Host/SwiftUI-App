import SwiftUI
import Calagopus

enum ServerSettingsAutoStartBehavior: String, CaseIterable, Identifiable {
    case always, unlessStopped, never

    var id: String {
        rawValue
    }

    init(_ behavior: CalagopusServerAutoStartBehavior) {
        switch behavior {
        case .always:
            self = .always
        case .unlessStopped:
            self = .unlessStopped
        case .never:
            self = .never
        }
    }

    var calagopusValue: CalagopusServerAutoStartBehavior {
        switch self {
        case .always:
            .always
        case .unlessStopped:
            .unlessStopped
        case .never:
            .never
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .always:
            "Always"
        case .unlessStopped:
            "Unless stopped"
        case .never:
            "Never"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .always:
            "Start when the node boots"
        case .unlessStopped:
            "Start unless it was manually stopped"
        case .never:
            "Stay offline until started manually"
        }
    }
}
