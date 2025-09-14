import SwiftUI

struct LogSection: View {
    var body: some View {
        Card("Logs") {
            VStack(alignment: .leading) {
                HStack {
                    HeaderCell("Actor")
                        .frame(width: 32, alignment: .leading)
                    
                    HeaderCell("Description")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HeaderCell("Status")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HeaderCell("Date")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 6)
                
                ForEach(Array(Project.sample.enumerated()), id: \.element.id) { index, log in
                    VStack(spacing: 6) {
                        HStack {
                            AvatarView(log.actor)
                                .frame(width: 32, alignment: .leading)
                                .clipped()
                            
                            Text(log.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            StatusPill(log.status)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(log.due.formatted(date: .abbreviated, time: .omitted))
                                .secondary()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if index < Project.sample.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    LogSection()
}
