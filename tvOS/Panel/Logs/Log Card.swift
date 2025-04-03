import SwiftUI
import PteroNet

struct LogCard: View {
    private let log: LogAttributes
    
    init(_ log: LogAttributes) {
        self.log = log
    }
    
    @State private var sheetDetails = false
    
    private var actor: LogActorAttributes? {
        log.relationships.actor.attributes
    }
    
    var body: some View {
        Button {
            if !log.properties.isEmpty {
                sheetDetails = true
            }
        } label: {
            HStack(spacing: 32) {
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
        LogCard(sampleJSON(.logAttributes))
    }
}
