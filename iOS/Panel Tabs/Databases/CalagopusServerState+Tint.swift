import SwiftUI
import Calagopus

extension CalagopusServerState {
    var tint: Color {
        switch self {
        case .running: .green
        case .starting, .stopping: .orange
        case .offline: .red
        }
    }
    
    var title: LocalizedStringKey {
        switch self {
        case .running: "Running"
        case .starting: "Starting"
        case .stopping: "Stopping"
        case .offline: "Offline"
        }
    }
}
