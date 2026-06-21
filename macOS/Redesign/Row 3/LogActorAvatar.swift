import SwiftUI
import Calagopus
import Kingfisher

struct LogActorAvatar: View {
    private let actor: LogActorAttributes?
    
    init(_ actor: LogActorAttributes?) {
        self.actor = actor
    }
    
    var body: some View {
        if let actor {
            KFImage(URL(string: actor.image))
                .resizable()
                .frame(28)
                .clipShape(.circle)
                .accessibilityLabel(actor.username)
        } else {
            Image(systemName: "pc")
                .resizable()
                .scaledToFit()
                .frame(28)
                .accessibilityLabel("System")
        }
    }
}
