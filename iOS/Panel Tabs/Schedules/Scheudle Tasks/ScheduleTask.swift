import ScrechKit
import Calagopus

struct ScheduleTask: View {
    private let schedule: CalagopusServerSchedule
    private let task: CalagopusServerScheduleStep
    
    init(_ schedule: CalagopusServerSchedule, task: CalagopusServerScheduleStep) {
        self.schedule = schedule
        self.task = task
    }
    
    var body: some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: task.actionIcon)
                    .foregroundStyle(.gray)
                    .semibold()
#if os(tvOS)
                    .title2()
#endif
                VStack(alignment: .leading) {
                    Text(task.actionLabel)
                        .subheadline()
                    
                    let detail = Text(task.detail)
                        .foregroundStyle(.primary)
                    
                    detail
                        .secondary()
                        .lineLimit(1)
                }
                .caption2()
            }
            .foregroundStyle(.foreground)
        }
        .contextMenu {
            TaskContextMenu(schedule, task: task)
        }
    }
}

private extension CalagopusServerScheduleStep {
    var actionObject: [String: CalagopusJSON] {
        guard case .object(let object) = action else {
            return [:]
        }
        
        return object
    }
    
    var actionLabel: String {
        switch actionType {
        case "sleep": "Sleep"
        case "ensure": "Ensure"
        case "format": "Format"
        case "match_regex": "Match regex"
        case "wait_for_console_line": "Wait for console line"
        case "send_command": "Send command"
        case "send_power": "Send power"
        case "create_backup": "Create backup"
        case "restore_backup": "Restore backup"
        case "delete_backup": "Delete backup"
        case "move_backup": "Move backup"
        case "create_directory": "Create directory"
        case "write_file": "Write file"
        case "copy_file": "Copy file"
        case "delete_files": "Delete files"
        case "rename_files": "Rename files"
        case "compress_files": "Compress files"
        case "decompress_file": "Decompress file"
        case "update_startup_variable": "Update startup variable"
        case "update_startup_command": "Update startup command"
        case "update_startup_docker_image": "Update startup Docker image"
        default: actionType
        }
    }
    
    var detail: String {
        switch actionType {
        case "sleep":
            "Duration: \(actionObject["duration"]?.displayString ?? "-")"
            
        case "ensure":
            "Condition"
            
        case "format":
            actionObject["format"]?.displayString ?? "-"
            
        case "match_regex":
            actionObject["regex"]?.displayString ?? "-"
            
        case "wait_for_console_line":
            actionObject["contains"]?.displayString ?? "-"
            
        case "send_command":
            actionObject["command"]?.displayString ?? "-"
            
        case "send_power":
            actionObject["action"]?.displayString ?? "-"
            
        case "create_backup":
            actionObject["name"]?.displayString ?? "-"
            
        case "restore_backup", "delete_backup", "move_backup":
            backupSelectorDescription
            
        case "create_directory":
            actionObject["name"]?.displayString ?? "-"
            
        case "write_file", "copy_file", "decompress_file":
            actionObject["file"]?.displayString ?? "-"
            
        case "delete_files", "rename_files", "compress_files":
            actionObject["root"]?.displayString ?? "-"
            
        case "update_startup_variable":
            actionObject["env_variable"]?.displayString ?? "-"
            
        case "update_startup_command":
            actionObject["command"]?.displayString ?? "-"
            
        case "update_startup_docker_image":
            actionObject["image"]?.displayString ?? "-"
            
        default:
            "-"
        }
    }
    
    var actionIcon: String {
        switch actionType {
        case "sleep": "timer"
        case "ensure": "checkmark.shield"
        case "format": "textformat"
        case "match_regex": "text.magnifyingglass"
        case "wait_for_console_line", "send_command": "terminal"
        case "send_power": "bolt"
        case "create_backup": "externaldrive.badge.icloud"
        case "restore_backup": "arrow.up.bin"
        case "delete_backup": "trash"
        case "move_backup": "folder"
        case "create_directory": "folder.badge.plus"
        case "write_file": "doc.text"
        case "copy_file": "doc.on.doc"
        case "delete_files": "trash"
        case "rename_files": "pencil"
        case "compress_files": "archivebox"
        case "decompress_file": "archivebox.fill"
        case "update_startup_variable": "character.cursor.ibeam"
        case "update_startup_command": "play"
        case "update_startup_docker_image": "shippingbox"
        default: "exclamationmark.triangle"
        }
    }
    
    private var actionType: String {
        actionObject["type"]?.displayString ?? ""
    }
    
    private var backupSelectorDescription: String {
        guard case .object(let backup) = actionObject["backup"] else {
            return "-"
        }
        
        switch backup["mode"]?.displayString {
        case "latest":
            return "Latest backup"
            
        case "oldest":
            return "Oldest backup"
            
        case "uuid":
            return backup["uuid"]?.displayString ?? "Backup UUID"
            
        case "name":
            return backup["name"]?.displayString ?? "Backup name"
            
        default:
            return "-"
        }
    }
}

private extension CalagopusJSON {
    var displayString: String {
        switch self {
        case .null:
            ""
            
        case .bool(let value):
            value.description
            
        case .number(let value):
            if value.rounded() == value {
                Int(value).description
            } else {
                value.description
            }
            
        case .string(let value):
            value
            
        case .array, .object:
            ""
        }
    }
}

//#Preview {
//    List {
//        ScheduleTask(
//            PreviewProp.scheduleAttributes,
//            task: PreviewProp.scheduleTaskAttributes
//        )
//    }
//    .darkSchemePreferred()
//}
