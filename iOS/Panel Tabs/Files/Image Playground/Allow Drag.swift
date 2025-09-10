import SwiftUI

fileprivate struct AllowDrag: ViewModifier {
    private let url: URL?
    
    init(_ url: URL?) {
        self.url = url
    }
    
    func body(content: Content) -> some View {
        if let url {
            content
                .onDrag {
                    NSItemProvider(object: url as NSURL)
                }
        } else {
            content
        }
    }
}

extension View {
    func allowDrag(_ url: URL?) -> some View {
        self.modifier(AllowDrag(url))
    }
}
