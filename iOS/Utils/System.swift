import Foundation

final class System {
    static let lowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    
    static var isWatch: Bool {
#if os(watchOS)
        true
#else
        false
#endif
    }
    
    static var isTV: Bool {
#if os(tvOS)
        true
#else
        false
#endif
    }
}
