import ScrechKit
import PteroNet

struct LogCard: View {
    private let log: LogAttributes
    private let showInfoButton: Bool
    
    init(_ log: LogAttributes, showInfoButton: Bool = true) {
        self.log = log
        self.showInfoButton = showInfoButton
    }
    
    @State private var sheetDetails = false
    
    private var actor: LogActorAttributes? {
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
#if DEBUG
                Text(log.event)
                    .footnote()
                    .secondary()
#endif
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
    }
}

#Preview {
    List {
        LogCard(sampleJSON(.logAttributes))
    }
}
