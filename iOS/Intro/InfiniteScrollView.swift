import SwiftUI

struct InfiniteScrollView<Content: View>: View {
    var spacing = 10.0
    @ViewBuilder var content: Content
    
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        GeometryReader {
            let width = $0.size.width
            
            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    Group(subviews: content) { collection in
                        /// Posters
                        HStack(spacing: spacing) {
                            ForEach(collection) { view in
                                view
                            }
                        }
                        .onGeometryChange(for: CGSize.self) {
                            $0.size
                        } action: { newValue in
                            contentSize = .init(
                                width: newValue.width + spacing,
                                height: newValue.height
                            )
                        }
                        
                        /// Repeating Content for creating Infinite(Looping) ScrollView
                        let avgWidth = contentSize.width / CGFloat(collection.count)
                        let repeatingCount = contentSize.width > 0 ? Int((width / avgWidth).rounded()) + 1 : 1
                        
                        HStack(spacing: spacing) {
                            ForEach(0..<repeatingCount, id: \.self) { index in
                                Array(collection)[index % collection.count]
                            }
                        }
                    }
                }
                .background {
                    InfiniteScrollHelper($contentSize, declarationRate: .constant(.fast))
                }
            }
        }
    }
}

#Preview {
    Intro()
        .darkSchemePreferred()
}
