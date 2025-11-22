import SwiftUI

struct Intro: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var activeCard: IntroCard?
    @State private var scrollPosition = ScrollPosition()
    @State private var currentScrollOffset = 0.0
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
    @State private var initialAnimation = false
    @State private var titleProgress = 0.0
    @State private var scrollPhase: ScrollPhase = .idle
    @State private var fullScreenCover = false
    
    private let cards = [
        IntroCard(.intro1),
        IntroCard(.intro2),
        IntroCard(.intro3)
    ]
    
    init() {
        activeCard = cards.first
    }
    
    var body: some View {
        ZStack {
            AmbientBackground($activeCard, cards: cards)
                .animation(.easeInOut(duration: 1), value: activeCard)
            
            VStack(spacing: 40) {
                InfiniteScrollView {
                    ForEach(cards) {
                        CarouselCardView($0)
                    }
                }
                .scrollIndicators(.hidden)
                .scrollPosition($scrollPosition)
                .scrollClipDisabled()
                .containerRelativeFrame(.vertical) { value, _ in
                    value * 0.45
                }
                .onScrollPhaseChange { _, newPhase in
                    scrollPhase = newPhase
                }
                .onScrollGeometryChange(for: CGFloat.self) {
                    $0.contentOffset.x + $0.contentInsets.leading
                } action: { _, newValue in
                    currentScrollOffset = newValue
                    
                    guard reduceMotion == false else { return }
                    
                    if scrollPhase != .decelerating || scrollPhase != .animating {
                        let activeIndex = Int((currentScrollOffset / 220).rounded()) % cards.count
                        activeCard = cards[activeIndex]
                    }
                }
                .visualEffect { [initialAnimation] content, proxy in
                    content
                        .offset(y: !initialAnimation ? -(proxy.size.height + 200) : 0)
                }
                
                VStack(spacing: 4) {
                    Text("Welcome to")
                        .semibold()
                        .foregroundStyle(.white.secondary)
                        .blurOpacityEffect(initialAnimation)
                    
                    Text("Bisquit.Host")
                        .largeTitle(.bold)
                        .foregroundStyle(.white)
                        .textRenderer(TitleTextRenderer(titleProgress))
                        .padding(.bottom, 12)
                    
                    Text("Comprehensive hosting solutions for VDS, game servers, websites, and bots — customized to fit your projects")
                        .callout()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.secondary)
                        .blurOpacityEffect(initialAnimation)
                }
                
                Button {
                    // Cancel timer before leaving
                    timer.upstream.connect().cancel()
                    
                    fullScreenCover = true
                } label: {
                    Text("Get Started")
                        .semibold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .glassEffect()
                }
                .blurOpacityEffect(initialAnimation)
            }
            .safeAreaPadding(15)
        }
        .onAppear {
            Task {
                await activate()
            }
        }
        .onReceive(timer) { _ in
            guard !reduceMotion else { return }
            
            currentScrollOffset += 0.35
            scrollPosition.scrollTo(x: currentScrollOffset)
        }
        .fullScreenCover($fullScreenCover) {
            NavigationStack {
                StartPage()
            }
        }
    }
    
    private func activate() async {
        try? await Task.sleep(for: .seconds(0.35))
        
        withAnimation(.smooth(duration: 0.75, extraBounce: 0)) {
            initialAnimation = true
        }
        
        withAnimation(.smooth(duration: 2.5, extraBounce: 0).delay(0.3)) {
            titleProgress = 1
        }
    }
}

fileprivate extension View {
    func blurOpacityEffect(_ show: Bool) -> some View {
        self
            .blur(radius: show ? 0 : 2)
            .opacity(show ? 1 : 0)
            .scaleEffect(show ? 1 : 0.9)
    }
}

#Preview {
    Intro()
        .darkSchemePreferred()
}
