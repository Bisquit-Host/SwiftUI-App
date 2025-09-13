import SwiftUI

struct ProjectCard: View {
    var body: some View {
        Card("Logs") {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                GridRow {
                    HeaderCell("Project Name")
                    HeaderCell("Status")
                    HeaderCell("Progress")
                    HeaderCell("Total Tasks")
                    HeaderCell("Due Date")
                    HeaderCell("Owner")
                }
                
                ForEach(Project.sample) { p in
                    GridRow {
                        HStack {
                            Image(systemName: "folder")
                            
                            Text(p.name)
                        }
                        
                        StatusPill(status: p.status)
                        
                        ProgressBar(progress: p.progress)
                            .frame(maxWidth: 200)
                        
                        Text("\(p.done) / \(p.total)")
                            .secondary()
                        
                        Text(p.due.formatted(date: .abbreviated, time: .omitted))
                            .secondary()
                        
                        HStack(spacing: -8) {
                            ForEach(p.owners) {
                                AvatarView($0)
                                    .padding(.leading, 8)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    
                    Divider()
                }
            }
        }
    }
}

#Preview {
    ProjectCard()
}
