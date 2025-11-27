import SwiftUI

extension View {
    @ViewBuilder
    func allowDrag(_ url: URL?) -> some View {
        if let url {
            self.onDrag {
                NSItemProvider(object: url as NSURL)
            }
        } else {
            self
        }
    }
}
