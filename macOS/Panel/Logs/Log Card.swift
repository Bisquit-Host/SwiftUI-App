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
        LogCard(sampleJSON(.logAttributes))
    }
}
