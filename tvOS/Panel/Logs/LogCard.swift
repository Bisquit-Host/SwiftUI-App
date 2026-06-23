import SwiftUI
import Calagopus

struct LogCard: View {
    private let log: CalagopusServerLog
    
    init(_ log: CalagopusServerLog) {
        self.log = log
    }
    
    @State private var sheetDetails = false
    
    var body: some View {
        let actor = log.relationships.actor.attributes
        
        Button {
            if !log.properties.isEmpty {
                sheetDetails = true
            }
        } label: {
            HStack(spacing: 25) {
                LogCardImage(actor?.image)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 16) {
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
                }
                
                Spacer()
                
                LogCardTimestamp(log.timestamp)
                
                if !log.properties.isEmpty {
                    Image(systemName: "info.circle")
                        .title3(.semibold)
                        .secondary()
                }
            }
        }
        .sheet($sheetDetails) {
            LogMetaView(log.properties)
        }
    }
}

#Preview {
    List {
        LogCard(PreviewProp.logAttributes)
    }
    .darkSchemePreferred()
}
