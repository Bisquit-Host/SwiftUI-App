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
            
            Spacer()
            
            //            if !log.properties.isEmpty {
            //                Image(systemName: "info.circle")
            //                    .secondary()
            //            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
        .frame(minWidth: 200, maxWidth: 800)
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
