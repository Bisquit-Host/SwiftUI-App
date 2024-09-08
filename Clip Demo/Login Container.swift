import SwiftUI

struct LoginContainer: View {
    @Environment(NavState.self) private var navState
    
    var body: some View {
        @Bindable var navState = navState
        
        NavigationStack(path: $navState.path) {
            Intro()
                .withNavDestinations()
        }
        .environment(navState)
    }
}
