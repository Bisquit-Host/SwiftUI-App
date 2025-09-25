import SwiftUI

struct IntroAmbientBackground: View {
    @Binding private var activeCard: IntroCard?
    private let cards: [IntroCard]
    
    init(_ activeCard: Binding<IntroCard?>, cards: [IntroCard]) {
        _activeCard = activeCard
        self.cards = cards
    }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            ZStack {
                ForEach(cards) {
                    Image($0.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .frame(width: size.width, height: size.height)
                    /// Only showing the active card's Image
                        .opacity(activeCard?.id == $0.id ? 1 : 0)
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

//#Preview {
//    IntroAmbientBackground()
//    .darkSchemePreferred()
//}
