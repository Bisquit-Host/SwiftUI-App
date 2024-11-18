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
        HStack {
            if let image = actor?.image {
                KFImage(URL(string: image))
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(.rect(cornerRadius: 10))
            } else {
                Image(systemName: "apple.terminal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            }
            
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
                
                Text(log.event)
                    .footnote(design: .monospaced)
                
                Text(timeSinceISO(log.timestamp))
                    .footnote(.semibold)
            }
            
//            if !log.properties.isEmpty {
//                Spacer()
//                
//                Image(systemName: "info.circle")
//                    .secondary()
//            }
        }
//        .onTapGesture {
//            if !log.properties.isEmpty {
//                sheetDetails = true
//            }
//        }
//        .sheet($sheetDetails) {
//            LogViewParent(log.properties)
//                .presentationDragIndicator(.hidden)
//                .presentationDetents([.medium, .large],
//                                     selection: .constant(.medium)
//                )
//        }
    }
}

#Preview {
    List {
        LogCard(
            sampleJSON(.logAttributes)
        )
    }
}
