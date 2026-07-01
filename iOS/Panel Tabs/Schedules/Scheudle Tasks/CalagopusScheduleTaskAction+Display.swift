import Calagopus

extension CalagopusScheduleTaskAction {
    static var panelCases: [CalagopusScheduleTaskAction] {[
        .sleep,
        .ensure,
        .format,
        .matchRegex,
        .waitForConsoleLine,
        .sendPower,
        .sendCommand,
        .createBackup,
        .createDirectory,
        .writeFile,
        .copyFile,
        .deleteFiles,
        .renameFiles,
        .compressFiles,
        .decompressFile,
        .updateStartupVariable,
        .updateStartupCommand,
        .updateStartupDockerImage
    ]}
    
    var taskLabel: String {
        switch self { 
        case .sleep: "Sleep"
        case .ensure: "Ensure" 
        case .format: "Format"
        case .matchRegex: "Match regex"
        case .waitForConsoleLine: "Wait for console line"
        case .sendPower, .power: "Send power"
        case .sendCommand, .command: "Send command"
        case .createBackup, .backup: "Create backup"
        case .createDirectory: "Create directory"
        case .writeFile: "Write file"
        case .copyFile: "Copy file"
        case .deleteFiles: "Delete files" 
        case .renameFiles: "Rename files"
        case .compressFiles: "Compress files" 
        case .decompressFile: "Decompress file"
        case .updateStartupVariable: "Update startup variable"
        case .updateStartupCommand: "Update startup command"
        case .updateStartupDockerImage: "Update startup Docker image"
        }
    }
    
    var taskIcon: String {
        switch self {
        case .sleep: "timer"
        case .ensure: "checkmark.shield"
        case .format: "textformat"
        case .matchRegex: "text.magnifyingglass"
        case .waitForConsoleLine: "terminal"
        case .sendPower, .power: "bolt"
        case .sendCommand, .command: "terminal"
        case .createBackup, .backup: "externaldrive.badge.icloud"
        case .createDirectory: "folder.badge.plus"
        case .writeFile: "doc.text"
        case .copyFile: "doc.on.doc"
        case .deleteFiles: "trash"
        case .renameFiles: "pencil"
        case .compressFiles: "archivebox"
        case .decompressFile: "archivebox.fill"
        case .updateStartupVariable: "character.cursor.ibeam"
        case .updateStartupCommand: "play"
        case .updateStartupDockerImage: "shippingbox"
        }
    }
}
