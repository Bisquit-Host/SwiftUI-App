import SwiftUI

struct LoginContainer: View {
    @Environment(NavState.self) private var navState
    
    var body: some View {
        @Bindable var binding = navState
        
        NavigationStack(path: $binding.path) {
            Intro()
                .withNavDestinations()
        }
        .environment(navState)
    }
}
