import ScrechKit
import Calagopus

struct LogCard: View {
    private let log: CalagopusServerLog
    private let showInfoButton: Bool
    
    init(_ log: CalagopusServerLog, showInfoButton: Bool = true) {
        self.log = log
        self.showInfoButton = showInfoButton
    }
    
    @State private var sheetDetails = false
    
    private var actor: CalagopusLogActorAttributes? {
        log.relationships.actor.attributes
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    LogCardImage(actor?.image)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text(actor?.username ?? "System")
                                .semibold()
                            
                            Group {
                                if log.isApi {
                                    Text("API")
                                }
                                
                                if log.event.contains("SFTP") {
                                    Text("SFTP")
                                }
                            }
                            .subheadline(.semibold)
                            .secondary()
                        }
                        
                        LogCardTimestamp(log.timestamp)
                    }
                }
                
                LogCardEvent(log)
            }
            
            if !log.properties.isEmpty && showInfoButton {
                Spacer()
                
                SFButton("info.circle") {
                    if !log.properties.isEmpty && showInfoButton {
                        sheetDetails = true
                    }
                }
                .secondary()
            }
        }
        .sheet($sheetDetails) {
            LogMetaParent(log.properties)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.medium, .large], selection: .constant(.medium))
        }
#if DEBUG && !os(watchOS)
        .contextMenu {
            Text(log.event)
                .secondary()
        }
#endif
    }
}

#Preview {
    List {
        LogCard(PreviewProp.logAttributes)
    }
    .darkSchemePreferred()
}
