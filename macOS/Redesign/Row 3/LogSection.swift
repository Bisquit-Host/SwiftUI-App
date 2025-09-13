import SwiftUI

struct LogSection: View {
    var body: some View {
        Card("Logs") {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                GridRow {
                    HeaderCell("Actor")
                    HeaderCell("Project Name")
                    HeaderCell("Status")
                    HeaderCell("Due Date")
                }
                
                ForEach(Project.sample) { log in
                    GridRow {
                        HStack(spacing: -8) {
                            ForEach(log.actors) {
                                AvatarView($0)
                            }
                        }
                        
                        Text(log.name)
                        
                        StatusPill(log.status)
                        
                        Text(log.due.formatted(date: .abbreviated, time: .omitted))
                            .secondary()
                    }
                    .padding(.vertical, 6)
                    
                    Divider()
                }
            }
        }
    }
}

#Preview {
    LogSection()
}
