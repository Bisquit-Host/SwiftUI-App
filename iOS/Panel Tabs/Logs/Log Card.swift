import SwiftUI
import Kingfisher
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
                    if let image = actor?.image {
                        KFImage(URL(string: image))
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(.circle)
                    } else {
                        Image(systemName: "apple.terminal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    }
                    
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
                        
                        TimelineView(.everyMinute) { _ in
                            Text(timeSinceISO(log.timestamp))
                                .monospacedDigit()
                                .secondary()
                                .footnote()
                        }
                    }
                }
                
                LogCardEvent(log)
            }
            
            if !log.properties.isEmpty && showInfoButton {
                Spacer()
                
                Image(systemName: "info.circle")
                    .secondary()
            }
        }
        .onTapGesture {
            if !log.properties.isEmpty && showInfoButton {
                sheetDetails = true
            }
        }
        .sheet($sheetDetails) {
            LogMetaParent(log.properties)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.medium, .large], selection: .constant(.medium))
        }
    }
    
    private func timeSinceISO(_ date: String) -> LocalizedStringKey {
        let formatter = ISO8601DateFormatter()
        
        guard let date = formatter.date(from: date) else {
            return "-"
        }
        
        let sinceNowSeconds = Int(date.timeIntervalSinceNow * -1)
        
        guard sinceNowSeconds > 1 else {
            return "Now"
        }
        
        guard sinceNowSeconds > 60 else {
            return "\(sinceNowSeconds) seconds ago"
        }
        
        let sinceNowMinutes = sinceNowSeconds / 60
        guard sinceNowMinutes > 60 else {
            return "\(sinceNowMinutes) minutes ago"
        }
        
        let sinceNowHours = sinceNowMinutes / 60
        guard sinceNowHours > 24 else {
            return "\(sinceNowHours) hours ago"
        }
        
        let sinceNowDays = sinceNowHours / 24
        return "\(sinceNowDays) days ago"
    }
}

#Preview {
    List {
        LogCard(sampleJSON(.logAttributes))
    }
}
