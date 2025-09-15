import SwiftUI
import PteroNet

struct LogSectionCard: View {
    private let log: LogAttributes
    
    init(_ log: LogAttributes) {
        self.log = log
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                LogActorAvatar(log.relationships.actor.attributes)
                    .frame(width: 32, alignment: .leading)
                    .clipped()
                
                LogCardEvent(log)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(log.timestamp)
                    .secondary()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    LogSectionCard(PreviewProp.logAttributes)
}
