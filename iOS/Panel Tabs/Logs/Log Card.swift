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
                
                Text(eventDescription)
                    .footnote(design: .monospaced)
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
    
    private func eventProp(_ called: String) -> String {
        log.properties[called]?.description ?? "???"
    }
    
    private func subdomain() -> String {
        let subdomain = eventProp("domain")
        let domain = eventProp("subdomain")
        
        return "\(subdomain).\(domain)"
    }
    
    private func coreVersion() -> String {
        let version = eventProp("version")
        let build = eventProp("build")
        let type = eventProp("type")
        let deletefiles = eventProp("deletefiles")
        
        return "\(type) \(version) \(build) (delete files: \(deletefiles))"
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
    
    private var eventDescription: LocalizedStringKey {
        switch log.event {
            // Modpack
        case "server:modpack.install":
            "Installed modpack ID **`\(eventProp("modpack_id"))`**, version **`\(eventProp("modpack_version_id"))`** from **`\(eventProp("provider"))`**"
            
            // Schedules
        case "server:schedule.delete":
            "Deleted the **`\(eventProp("name"))`** schedule"
            
        case "server:schedule.create":
            "Created **`\(eventProp("name"))`** schedule"
            
        case "server:schedule.update":
            "Updated **`\(eventProp("name"))`** schedule"
            
        case "server:task.delete":
            "Deleted a task in your **`\(eventProp("name"))`** schedule"
            
        case "server:task.create":
            "Created a new **`\(eventProp("action"))`** task in your **`\(eventProp("name"))`** schedule"
            
        case "server:task.update":
            "Updated a task in your **`\(eventProp("name"))`** schedule"
            
            // Users
        case "server:subuser.delete":
            "Removed **`\(eventProp("email"))`** as a subuser"
            
        case "server:subuser.create":
            "Added **`\(eventProp("email"))`** as a subuser"
            
        case "server:subuser.update":
            "Updated the subuser permissions for **`\(eventProp("email"))`** as a subuser"
            
            // Versions
        case "server:version.install":
            "Installed **`\(coreVersion())`**"
            
            // Startup
        case "server:startup.edit":
            "Changed the **`\(eventProp("variable"))`** variable from **`\(eventProp("old"))`** to **`\(eventProp("new"))`**"
            
        case "server:startup.image":
            "Updated the Docker Image for the server from **`\(eventProp("old"))`** to **`\(eventProp("new"))`**"
            
            // Allocation
        case "server:allocation.delete":
            "Deleted the **`\(eventProp("allocation"))`** allocation"
            
        case "server:allocation.primary":
            "Set **`\(eventProp("allocation"))`** as the primary server allocation"
            
        case "server:allocation.create":
            "Added **`\(eventProp("allocation"))`** to the server"
            
        case "server:allocation.notes":
            "Updated the notes for **`\(eventProp("allocation"))`** from **`\(eventProp("old"))`** to **`\(eventProp("new"))`**"
            
            // DB
        case "server:database.delete":
            "Deleted database **`\(eventProp("name"))`**"
            
        case "server:database.rotate-password":
            "Password rotated for database **`\(eventProp("name"))`**"
            
        case "server:database.create":
            "Created new database **`\(eventProp("name"))`**"
            
            // Settings
        case "server:settings.description":
            "Changed the server description from **`\(eventProp("old"))`** to **`\(eventProp("new"))`**"
            
        case "server:settings.rename":
            "Renamed the server from **`\(eventProp("old"))`** to **`\(eventProp("new"))`**"
            
        case "server:reinstall":
            "Reinstalled server"
            
            // Power
        case "server:power.start":
            "Started the server"
            
        case "server:power.stop":
            "Stopped the server"
            
        case "server:power.restart":
            "Restarted the server"
            
        case "server:power.kill":
            "Killed the server process"
            
            // Console
        case "server:console.command":
            "Executed **`\(eventProp("command"))`** on the server"
            
            // Files
        case "server:file.copy":
            "Created a copy of **`\(eventProp("file"))`**"
            
        case "server:file.read":
            "Viewed the contents of **`\(eventProp("file"))`**"
            
        case "server:file.compress":
            "Compressed **`\(eventProp("files"))`** in **`\(eventProp("directory"))`**"
            
        case "server:file.decompress":
            "Decompressed **`\(eventProp("files"))`** in **`\(eventProp("directory"))`**"
            
        case "server:file.download":
            "Downloaded **`\(eventProp("file"))`**"
            
            // Array
        case "server:file.delete":
            "Deleted **`\(eventProp("files"))`**"
            
        case "server:file.write":
            "Wrote new content to **`\(eventProp("file"))`**"
            
            // Backups
        case "server:backup.delete":
            "Deleted the **`\(eventProp("name"))`** backup"
            
        case "server:backup.complete":
            "Marked the **`\(eventProp("name"))`** backup as complete"
            
        case "server:backup.lock":
            "Locked the **`\(eventProp("name"))`** backup"
            
        case "server:backup.unlock":
            "Unlocked **`\(eventProp("name"))`** backup"
            
        case "server:backup.start":
            "Started a new backup **`\(eventProp("name"))`**"
            
        case "server:backup.download":
            "Downloaded the **`\(eventProp("name"))`** backup"
            
        case "server:backup.restore-complete":
            "Completed restoration of the **`\(eventProp("name"))`** backup"
            
        case "server:backup.restore":
            "Restored the **`\(eventProp("name"))`** backup (truncate: **`\(eventProp("truncate"))`**)"
            
            // Subdomains
        case "server:subdomain.delete":
            "Created the **`\(subdomain())`** subdomain"
            
        case "server:subdomain.create":
            "Deleted the **`\(subdomain())`** subdomain"
            
        default:
            LocalizedStringKey(log.event)
        }
    }
}

#Preview {
    List {
        LogCard(sampleJSON(.logAttributes))
    }
}
