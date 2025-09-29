import SwiftUI

struct IntroAmbientBackground: View {
    @Binding private var activeCard: IntroCard?
    private let cards: [IntroCard]
    
    init(_ activeCard: Binding<IntroCard?>, cards: [IntroCard]) {
        _activeCard = activeCard
        self.cards = cards
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(cards) {
                    IntroAmbientBackgroundCard($activeCard, card: $0, size: geo.size)
                }
                
                Rectangle()
                    .fill(.black.opacity(0.45))
                    .ignoresSafeArea()
            }
            .compositingGroup()
            .blur(radius: 90, opaque: true)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    @Previewable @State var activeCard: IntroCard?
    
    IntroAmbientBackground($activeCard, cards: [])
        .darkSchemePreferred()
}
