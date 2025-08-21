import SwiftUI
import PteroNet

struct LogCardEvent: View {
    private let log: LogAttributes
    
    init(_ log: LogAttributes) {
        self.log = log
    }
    
    var body: some View {
        Text(eventDescription)
            .footnote(design: .monospaced)
    }
    
    private func eventProp(_ called: String) -> String {
        log.properties[called]?.description ?? "???"
    }
    
    private func subdomain() -> String {
        let subdomain = eventProp("domain")
        let domain = eventProp("subdomain")
        
        return subdomain + "." + domain
    }
    
    private func coreVersion() -> String {
        let version = eventProp("version")
        let build = eventProp("build")
        let type = eventProp("type")
        let deletefiles = eventProp("deletefiles")
        
        return "\(type) \(version) \(build) (delete files: \(deletefiles))"
    }
    
    private var eventDescription: LocalizedStringKey {
        switch log.event {
            // Modpack
        case "server:modpack.install":
            "Installed modpack ID \"**`\(eventProp("modpack_id"))`**\", version \"**`\(eventProp("modpack_version_id"))`**\" from \"**`\(eventProp("provider"))`**\""
            
            // Schedules
        case "server:schedule.delete":
            "Deleted the \"**`\(eventProp("name"))`**\" schedule"
            
        case "server:schedule.create":
            "Created \"**`\(eventProp("name"))`**\" schedule"
            
        case "server:schedule.update":
            "Updated \"**`\(eventProp("name"))`**\" schedule"
            
        case "server:task.delete":
            "Deleted a task in your \"**`\(eventProp("name"))`**\" schedule"
            
        case "server:task.create":
            "Created a new \"**`\(eventProp("action"))`**\" task in your \"**`\(eventProp("name"))`**\" schedule"
            
        case "server:task.update":
            "Updated a task in your \"**`\(eventProp("name"))`**\" schedule"
            
            // Users
        case "server:subuser.delete":
            "Removed \"**`\(eventProp("email"))`**\" as a subuser"
            
        case "server:subuser.create":
            "Added \"**`\(eventProp("email"))`**\" as a subuser"
            
        case "server:subuser.update":
            "Updated the subuser permissions for \"**`\(eventProp("email"))`**\" as a subuser"
            
            // Versions
        case "server:version.install":
            "Installed \"**`\(coreVersion())`**\""
            
            // Startup
        case "server:startup.edit":
            "Changed the \"**`\(eventProp("variable"))`**\" variable from \"**`\(eventProp("old"))`**\" to \"**`\(eventProp("new"))`**\""
            
        case "server:startup.image":
            "Updated the Docker Image for the server from \"**`\(eventProp("old"))`**\" to \"**`\(eventProp("new"))`**\""
            
            // Allocation
        case "server:allocation.delete":
            "Deleted the \"**`\(eventProp("allocation"))`**\" allocation"
            
        case "server:allocation.primary":
            "Set \"**`\(eventProp("allocation"))`**\" as the primary server allocation"
            
        case "server:allocation.create":
            "Added \"**`\(eventProp("allocation"))`**\" to the server"
            
        case "server:allocation.notes":
            "Updated the notes for \"**`\(eventProp("allocation"))`**\" from \"**`\(eventProp("old"))`**\" to \"**`\(eventProp("new"))`**\""
            
            // DB
        case "server:database.delete":
            "Deleted database \"**`\(eventProp("name"))`**\""
            
        case "server:database.rotate-password":
            "Password rotated for database \"**`\(eventProp("name"))`**\""
            
        case "server:database.create":
            "Created new database \"**`\(eventProp("name"))`**\""
            
            // Settings
        case "server:settings.description":
            "Changed the server description from \"**`\(eventProp("old"))`**\" to \"**`\(eventProp("new"))`**\""
            
        case "server:settings.rename":
            "Renamed the server from \"**`\(eventProp("old"))`**\" to \"**`\(eventProp("new"))`**\""
            
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
            "Executed \"**`\(eventProp("command"))`**\" on the server"
            
            // Files
        case "server:file.copy":
            "Created a copy of \"**`\(eventProp("file"))`**\""
            
        case "server:file.read":
            "Viewed the contents of \"**`\(eventProp("file"))`**\""
            
        case "server:file.compress":
            "Compressed \"**`\(eventProp("files"))`**\" in \"**`\(eventProp("directory"))`**\""
            
        case "server:file.decompress":
            "Decompressed \"**`\(eventProp("files"))`**\" in \"**`\(eventProp("directory"))`**\""
            
        case "server:file.download":
            "Downloaded \"**`\(eventProp("file"))`**\""
            
            // Array
        case "server:file.delete":
            "Deleted \"**`\(eventProp("files"))`**\""
            
        case "server:file.write":
            "Wrote new content to \"**`\(eventProp("file"))`**\""
            
            // Backups
        case "server:backup.delete":
            "Deleted the \"**`\(eventProp("name"))`**\" backup"
            
        case "server:backup.complete":
            "Marked the \"**`\(eventProp("name"))`**\" backup as complete"
            
        case "server:backup.lock":
            "Locked the \"**`\(eventProp("name"))`**\" backup"
            
        case "server:backup.unlock":
            "Unlocked \"**`\(eventProp("name"))`**\" backup"
            
        case "server:backup.start":
            "Started a new backup \"**`\(eventProp("name"))`**\""
            
        case "server:backup.download":
            "Downloaded the \"**`\(eventProp("name"))`**\" backup"
            
        case "server:backup.restore-complete":
            "Completed restoration of the \"**`\(eventProp("name"))`**\" backup"
            
        case "server:backup.restore":
            "Restored the \"**`\(eventProp("name"))`**\" backup (truncate: \"**`\(eventProp("truncate"))`**\")"
            
            // Subdomains
        case "server:subdomain.delete":
            "Created the \"**`\(subdomain())`**\" subdomain"
            
        case "server:subdomain.create":
            "Deleted the \"**`\(subdomain())`**\" subdomain"
            
        default:
            LocalizedStringKey(log.event)
        }
    }
}

//#Preview {
//    LogCardEvent()
//}
