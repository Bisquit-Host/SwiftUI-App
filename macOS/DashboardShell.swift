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

#Preview {
    DashboardShell()
        .darkSchemePreferred()
}
