import ScrechKit
import PteroNet

// MARK: 1
// Backups
// DB's
// Sudomains
// Schedules
// Users
// Allocations

// MARK: 2
// Console
// Files
// Location

// MARK: 3
// Logs

// MARK: Toolbar
// Setup
// Settings

struct DashboardShell: View {
    @State private var selection: SidebarItem? = .dashboard
    
    var body: some View {
        NavigationSplitView {
            DashboardSidebar(selection: $selection)
        } detail: {
            switch selection {
            case .dashboard, .none: DashboardView()
            case .inbox:            Placeholder(title: "Inbox")
            case .project:          Placeholder(title: "Project")
            case .calendar:         Placeholder(title: "Calendar")
            case .reports:          Placeholder(title: "Reports")
            case .help:             Placeholder(title: "Help & Center")
            case .settings:         Placeholder(title: "Settings")
            }
        }
    }
}

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard",
         inbox = "Inbox",
         project = "Project",
         calendar = "Calendar",
         reports = "Reports",
         help = "Help & Center",
         settings = "Settings"
    
    var id: String {
        rawValue
    }
    
    var icon: String {
        switch self {
        case .dashboard: "rectangle.grid.2x2"
        case .inbox: "tray"
        case .project: "folder"
        case .calendar: "calendar"
        case .reports: "chart.bar"
        case .help: "questionmark.circle"
        case .settings: "gear"
        }
    }
}

struct DashboardSidebar: View {
    @Binding var selection: SidebarItem?
    
    var body: some View {
        List(selection: $selection) {
            HStack(spacing: 12) {
                Image(systemName: "cube")
                    .imageScale(.large)
                
                Text("Taskplus")
                    .headline()
            }
            .padding(.vertical, 8)
            
            Section {
                ForEach(SidebarItem.allCases) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .tag(item)
                }
            }
        }
        .listStyle(.sidebar)
    }
}

struct Placeholder: View {
    var title: String
    
    var body: some View {
        ZStack {
            Color(.windowBackgroundColor)
            
            VStack(spacing: 10) {
                Image(systemName: "square.grid.3x1.folder.fill.badge.plus")
                    .fontSize(48)
                
                Text(title)
                    .title(.semibold)
            }
        }
        .ignoresSafeArea()
    }
}

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

struct Card<Content: View, Trailing: View>: View {
    private let title: String
    private let trailing: Trailing
    private let content: Content
    
    init(
        title: String,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.trailing = trailing()
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .headline()
                
                Spacer()
                
                trailing
            }
            
            content
        }
        .padding(16)
        .background(.thinMaterial, in: .rect(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.05))
        }
    }
}

struct StatTile: View {
    var title: String
    var value: Int
    var icon: String
    
    var body: some View {
        Button {
            
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .fontSize(32)
                    .frame(45)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .subheadline()
                        .secondary()
                    
                    Text(value)
                        .title2(.semibold)
                }
                
                Spacer()
            }
            .padding(16)
            .background(.thinMaterial, in: .rect(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.05))
            }
        }
        .buttonStyle(.plain)
    }
}

struct HeaderCell: View {
    var text: String
    
    init(_ t: String) {
        text = t
    }
    
    var body: some View {
        Text(text)
            .caption()
            .secondary()
    }
}

struct ProgressBar: View {
    var progress: Double
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.white.opacity(0.08))
                .frame(height: 8)
            
            Capsule()
                .frame(width: nil, height: 8)
                .overlay {
                    GeometryReader { geo in
                        Capsule()
                            .fill(.white.opacity(0.2))
                            .frame(width: geo.size.width * progress)
                    }
                }
                .opacity(0)
        }
        .overlay {
            GeometryReader { geo in
                Capsule()
                    .fill(.blue)
                    .frame(width: geo.size.width * progress, height: 8)
            }
        }
    }
}

struct StatusPill: View {
    var status: Project.Status
    
    var body: some View {
        Text(status.title)
            .caption(.semibold)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(status.bg, in: .capsule)
    }
}

struct ProjectPill: View {
    var project: ProjectTag
    
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(project.color)
                .frame(width: 16, height: 12)
            
            Text(project.name)
                .subheadline()
        }
    }
}

struct AvatarView: View, Identifiable {
    let person: Person
    
    var id: UUID {
        person.id
    }
    
    init(_ p: Person) {
        person = p
    }
    
    var body: some View {
        Text(person.initials)
            .caption(.bold)
            .frame(28)
            .background {
                Circle()
                    .fill(person.tint)
            }
            .overlay {
                Circle()
                    .stroke(.black.opacity(0.3))
            }
            .foregroundStyle(.white)
            .accessibilityLabel(person.name)
    }
}

struct AvatarStack: View {
    var body: some View {
        HStack(spacing: -10) {
            AvatarView(.michael)
            AvatarView(.john)
            AvatarView(.dawne)
        }
    }
}

struct TaskItem: Identifiable {
    let id = UUID()
    let name: String
    let dateCreated: Date
    let project: ProjectTag
    
    static let sample: [TaskItem] = [
        .init(name: "File 1", dateCreated: .init(timeIntervalSinceNow: 0), project: .fintech),
        .init(name: "File 2", dateCreated: .init(timeIntervalSinceNow: 0), project: .brodo),
        .init(name: "File 3", dateCreated: .init(timeIntervalSinceNow: 0), project: .hr),
        .init(name: "File 4", dateCreated: .init(timeIntervalSinceNow: 0), project: .lucas),
        .init(name: "File 5", dateCreated: .init(timeIntervalSinceNow: 0), project: .allInOne)
    ]
}

struct ProjectTag: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    
    static let fintech = ProjectTag(name: "Fintech Project", color: .blue)
    static let brodo = ProjectTag(name: "Brodo Redesign", color: .purple)
    static let hr = ProjectTag(name: "HR Setup", color: .cyan)
    static let lucas = ProjectTag(name: "Lucas Projects", color: .indigo)
    static let allInOne = ProjectTag(name: "All in One Project", color: .pink)
}

struct Bar: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
    
    static let sample = [
        Bar(label: "Mon", value: 82),
        Bar(label: "Tue", value: 51),
        Bar(label: "Wed", value: 86),
        Bar(label: "Thu", value: 45),
        Bar(label: "Fri", value: 82)
    ]
}

struct Project: Identifiable {
    let id = UUID()
    let name: String
    let status: Status
    let progress: Double
    let done: Int
    let total: Int
    let due: Date
    let owners: [Person]
    
    enum Status {
        case inProgress, completed, onHold
        
        var title: String {
            switch self {
            case .inProgress: "In Progress"
            case .completed: "Completed"
            case .onHold: "On Hold"
            }
        }
        
        var bg: Color {
            switch self {
            case .inProgress: .blue.opacity(0.2)
            case .completed: .green.opacity(0.2)
            case .onHold: .gray.opacity(0.2)
            }
        }
    }
    
    static let sample: [Project] = [
        .init(name: "Fintech Project", status: .inProgress, progress: 0.7, done: 14, total: 20, due: .now, owners: [.michael]),
        .init(name: "Brodo Redesign", status: .completed, progress: 1, done: 25, total: 25, due: .now.addingTimeInterval(60 * 60 * 24 * 4), owners: [.john]),
        .init(name: "HR Setup", status: .onHold, progress: 0.7, done: 8, total: 20, due: .now.addingTimeInterval(60 * 60 * 24 * 66), owners: [.dawne])
    ]
}

struct Person: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let tint: Color
    
    static let michael = Person(name: "Michael M", initials: "MM", tint: .orange)
    static let john = Person(name: "John C", initials: "JC", tint: .purple)
    static let dawne = Person(name: "Dawne A", initials: "DA", tint: .blue)
}

#Preview {
    DashboardShell()
        .darkSchemePreferred()
}
