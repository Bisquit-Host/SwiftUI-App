import SwiftUI

struct IntroAmbientBackgroundCard: View {
    @Binding private var activeCard: IntroCard?
    private let card: IntroCard
    private let size: CGSize
    
    init(_ activeCard: Binding<IntroCard?>, card: IntroCard, size: CGSize) {
        _activeCard = activeCard
        self.card = card
        self.size = size
    }
    
    var body: some View {
        Image(card.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .frame(width: size.width, height: size.height)
        /// Only showing the active card's Image
            .opacity(activeCard?.id == card.id ? 1 : 0)
    }
}

//#Preview {
//    IntroAmbientBackgroundCard()
//        .darkSchemePreferred()
//}
