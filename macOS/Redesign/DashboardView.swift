import SwiftUI

struct DashboardView: View {
    @State private var search = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                statRow
                
                HStack(alignment: .top, spacing: 20) {
                    tasksCard
                    performanceCard
                }
                
                projectsCard
            }
            .padding(24)
        }
        .navigationTitle("Server name")
        .navigationSubtitle("Server description")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                //            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Text("Last Updated 12 May 2025")
                        .secondary()
                        .footnote()
                    
                    AvatarStack()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.controlBackgroundColor))
    }
    
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome Back, John Connor! 👋")
                .title(.bold)
            
            Text("4 Tasks Due Today, 2 Overdue Tasks, 8 Upcoming Deadlines (This Week)")
                .secondary()
        }
    }
    
    var statRow: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatTile(title: "Backups", value: 15, icon: "archivebox")
                StatTile(title: "Users", value: 23, icon: "person.2")
                StatTile(title: "Databases", value: 10, icon: "tray")
                StatTile(title: "Shedules", value: 50, icon: "calendar")
            }
            
            HStack(spacing: 16) {
                StatTile(title: "Allocations", value: 23, icon: "text.magnifyingglass")
                StatTile(title: "Sudomains", value: 23, icon: "globe")
                
                StatTile(title: "Modpacks", value: 10, icon: "hammer")
                    .disabled(true)
                
                StatTile(title: "Versions", value: 50, icon: "hammer")
                    .disabled(true)
            }
        }
    }
    
    var tasksCard: some View {
        Card(title: "Files") {
            VStack(spacing: 12) {
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
    
    var performanceCard: some View {
        Card(title: "Performance") {
            Text("86%")
                .largeTitle(.bold)
        } content: {
            VStack(alignment: .leading, spacing: 16) {
                Text("+15% vs last Week")
                    .secondary()
                
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(Bar.sample) { bar in
                        VStack {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: 30, height: CGFloat(bar.value))
                                .overlay(alignment: .bottom) {
                                    Text("\(bar.value)%")
                                        .caption2()
                                        .padding(.bottom, 4)
                                }
                            
                            Text(bar.label)
                                .caption()
                                .secondary()
                        }
                    }
                }
            }
        }
        .frame(width: 360)
    }
    
    var projectsCard: some View {
        Card(title: "List Projects") {
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
