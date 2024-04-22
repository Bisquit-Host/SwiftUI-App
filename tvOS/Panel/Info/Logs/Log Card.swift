import ScrechKit
import Kingfisher
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
                if let image = actor?.image {
                    KFImage(URL(string: image))
                        .resizable()
                        .frame(width: 64, height: 64)
                        .clipShape(.circle)
                } else {
                    Image(systemName: "apple.terminal")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                }
                
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
                    
                    Text(log.event)
                        .footnote(.semibold, design: .monospaced)
                }
                
                Spacer()
                
                Text(timeSinceISO(log.timestamp))
                    .footnote()
                
                if !log.properties.isEmpty {
                    Image(systemName: "info.circle")
                        .title3(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .sheet($sheetDetails) {
            LogDetailView(log.properties)
        }
    }
}

#Preview {
    List {
        LogCard(sampleJSON(.logAttributes))
    }
}
