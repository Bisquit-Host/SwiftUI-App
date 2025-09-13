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
                
                ForEach(Project.sample) { proj in
                    GridRow {
                        HStack {
                            Image(systemName: "folder")
                            
                            Text(proj.name)
                        }
                        
                        StatusPill(status: proj.status)
                        
                        ProgressBar(progress: proj.progress)
                            .frame(maxWidth: 200)
                        
                        Text("\(proj.done) / \(proj.total)")
                            .secondary()
                        
                        Text(proj.due.formatted(date: .abbreviated, time: .omitted))
                            .secondary()
                        
                        HStack(spacing: -8) {
                            ForEach(proj.owners) {
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
