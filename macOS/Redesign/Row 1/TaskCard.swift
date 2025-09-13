import SwiftUI

struct TaskCard: View {
    @State private var search = ""
    
    var body: some View {
        Card(title: "Files") {
            VStack(spacing: 32) {
                HStack {
                    TextField("Search here", text: $search)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                        
                    }
                    .buttonStyle(.bordered)
                }
                
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                    GridRow {
                        HeaderCell("Name")
                        HeaderCell("Size")
                        HeaderCell("Date")
                    }
                    
                    ForEach(TaskItem.sample) { task in
                        GridRow {
                            HStack {
                                Circle()
                                    .frame(width: 10)
                                
                                Text(task.name)
                            }
                            
                            ProjectPill(project: task.project)
                            
                            Text(task.dateCreated.formatted(date: .abbreviated, time: .omitted))
                                .secondary()
                        }
                        .padding(.vertical, 6)
                        
                        Divider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
