import SwiftUI
import OSLog

@Observable
final class NavState {
    var path = NavigationPath()
    
    func navigate(_ navDestination: NavDestinations) {
        path.append(navDestination)
    }
    
    func dismiss() {
        guard !path.isEmpty else {
            Logger().error("Nav path is empty")
            return
        }
        
        path.removeLast()
    }
    
    func clear() {
        path = .init()
    }
}
