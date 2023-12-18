//#if canImport(ActivityKit)
#if os(iOS)
import ActivityKit

struct ActivityViewState: Sendable {
    var activityState: ActivityState
    var contentState: WidgetsAttributes.ContentState
    var pushToken: String? = nil
    
    var shouldShowEndControls: Bool {
        switch activityState {
        case .active, .stale:
            true
            
        case .ended, .dismissed:
            false
            
        @unknown default:
            false
        }
    }
    
    var updateControlDisabled = false
    
    var shouldShowUpdateControls: Bool {
        switch activityState {
        case .active, .stale:
            true
            
        case .ended, .dismissed:
            false
            
        @unknown default:
            false
        }
    }
    
    var isStale: Bool {
        activityState == .stale
    }
}
#endif
