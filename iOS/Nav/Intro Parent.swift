import SwiftUI

struct IntroParent: View {
    var body: some View {
#if os(iOS)
        if #available(iOS 18, *) {
            Intro()
        } else {
            StartPage()
        }
#else
        Intro()
#endif
    }
}

#Preview {
    IntroParent()
}
