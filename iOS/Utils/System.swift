import SwiftUI

final class System {
    static let lowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    
    static var isWatch: Bool {
#if os(watchOS)
        true
#else
        false
#endif
    }
}
