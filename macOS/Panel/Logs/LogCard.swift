import SwiftUI
import PteroNet

struct LogCard: View {
    private let log: LogAttributes
    
    init(_ log: LogAttributes) {
        self.log = log
    }
    
    var body: some View {
        let actor = log.relationships.actor.attributes
        
        HStack {
            LogCardImage(actor?.image)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(actor?.username ?? "System")
                    
                    Group {
                        if log.isApi {
                            Text("API")
                        }
                        
                        if log.event.contains("SFTP") {
                            Text("SFTP")
                        }
                    }
                    .subheadline(.semibold)
                    .foregroundStyle(.blue)
                }
                
                LogCardEvent(log)
                
                LogCardTimestamp(log.timestamp)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
        .frame(minWidth: 200, maxWidth: 800)
    }
}

#Preview {
    List {
        LogCard(PreviewProp.logAttributes)
    }
    .darkSchemePreferred()
}
