import SwiftUI

struct InfoTabBackground: View {
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        Image(scheme == .dark ? .darkBackgroundInfo : .lightBackgroundInfo)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

#Preview {
    InfoTabBackground()
}
