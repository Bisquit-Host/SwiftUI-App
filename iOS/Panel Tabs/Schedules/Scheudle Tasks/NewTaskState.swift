import Foundation
import Calagopus

struct NewTaskState {
    var action: CalagopusScheduleTaskAction = .sleep
    var duration = "1000"
    var primaryValue = ""
    var secondaryValue = ""
    var listValue = ""
    var powerAction = "start"
    var archiveFormat = "tar_gz"
    var ignoreFailure = false
    var foreground = false
    var append = false
    var caseInsensitive = false
    var timeout = "5000"
    var backupSelectionMode = "latest"
    var backupGroupID: String?
    var targetBackupGroupID: String?
    var selectOldestNamedBackup = false
    var truncateDirectory = false
    var restoreStartup = false
    
    var hasValidActionInput: Bool {
        switch action {
        case .sleep:
            guard let duration = Int(duration) else {
                return false
            }
            
            return (1...86_400_000).contains(duration)
            
        case .waitForConsoleLine:
            guard let timeout = Int(timeout) else {
                return false
            }
            
            return (1...86_400_000).contains(timeout)
            
        case .restoreBackup, .deleteBackup, .moveBackup:
            guard backupSelectionMode == "uuid" || backupSelectionMode == "name" else {
                return true
            }
            
            return !primaryValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
        default:
            return true
        }
    }
    
    func makeTask(order: Int?) -> CalagopusScheduleTaskCreate {
        .init(order: order, action: actionPayload)
    }
    
    private var actionPayload: CalagopusJSON {
        switch action {
        case .sleep:
            .object(["type": .string(action.scheduleType), "duration": .number(Double(duration) ?? 0)])
            
        case .ensure:
            .object(["type": .string(action.scheduleType), "condition": .object(["type": .string("none")])])
            
        case .format:
            .object(["type": .string(action.scheduleType), "format": .string(primaryValue), "output_into": .object(["variable": .string(secondaryValue)])])
            
        case .matchRegex:
            .object(["type": .string(action.scheduleType), "input": .string(primaryValue), "regex": .string(secondaryValue), "output_into": .array(files.map { .object(["variable": $0]) })])
            
        case .waitForConsoleLine:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "contains": .string(primaryValue), "case_insensitive": .bool(caseInsensitive), "timeout": .number(Double(timeout) ?? 0), "output_into": outputInto])
            
        case .sendPower, .power:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "action": .string(powerAction)])
            
        case .sendCommand, .command:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "command": .string(primaryValue)])
            
        case .createBackup, .backup:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "foreground": .bool(foreground), "name": optionalString(primaryValue), "backup_group_uuid": optionalString(backupGroupID), "ignored_files": .array(files)])
            
        case .restoreBackup:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "truncate_directory": .bool(truncateDirectory), "restore_startup": .bool(restoreStartup), "backup": backupSelector])
            
        case .deleteBackup:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "backup": backupSelector])
            
        case .moveBackup:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "backup": backupSelector, "backup_group_uuid": optionalString(targetBackupGroupID)])
            
        case .createDirectory:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "root": .string(primaryValue), "name": .string(secondaryValue)])
            
        case .writeFile:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "append": .bool(append), "file": .string(primaryValue), "content": .string(secondaryValue)])
            
        case .copyFile:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "foreground": .bool(foreground), "file": .string(primaryValue), "destination": .string(secondaryValue)])
            
        case .deleteFiles:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "root": .string(primaryValue), "files": .array(files)])
            
        case .renameFiles:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "root": .string(primaryValue), "files": .array(renameFiles)])
            
        case .compressFiles:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "foreground": .bool(foreground), "root": .string(primaryValue), "files": .array(files), "format": .string(archiveFormat), "name": .string(secondaryValue)])
            
        case .decompressFile:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "foreground": .bool(foreground), "root": .string(primaryValue), "file": .string(secondaryValue)])
            
        case .updateStartupVariable:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "env_variable": .string(primaryValue), "value": .string(secondaryValue)])
            
        case .updateStartupCommand:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "command": .string(primaryValue)])
            
        case .updateStartupDockerImage:
            .object(["type": .string(action.scheduleType), "ignore_failure": .bool(ignoreFailure), "image": .string(primaryValue)])
        }
    }
    
    private var files: [CalagopusJSON] {
        listValue
            .split(whereSeparator: \.isNewline)
            .map { .string(String($0)) }
    }
    
    private var renameFiles: [CalagopusJSON] {
        listValue
            .split(whereSeparator: \.isNewline)
            .map {
                let parts = $0.split(separator: "=", maxSplits: 1).map(String.init)
                return .object(["from": .string(parts.first ?? ""), "to": .string(parts.last ?? "")])
            }
    }
    
    private var outputInto: CalagopusJSON {
        secondaryValue.isEmpty ? .null : .object(["variable": .string(secondaryValue)])
    }
    
    private var backupSelector: CalagopusJSON {
        switch backupSelectionMode {
        case "oldest":
            .object(["mode": .string("oldest"), "backup_group_uuid": optionalString(backupGroupID)])
            
        case "uuid":
            .object(["mode": .string("uuid"), "uuid": .string(primaryValue)])
            
        case "name":
            .object(["mode": .string("name"), "name": .string(primaryValue), "backup_group_uuid": optionalString(backupGroupID), "oldest": .bool(selectOldestNamedBackup)])
            
        default:
            .object(["mode": .string("latest"), "backup_group_uuid": optionalString(backupGroupID)])
        }
    }
    
    private func optionalString(_ value: String) -> CalagopusJSON {
        value.isEmpty ? .null : .string(value)
    }
    
    private func optionalString(_ value: String?) -> CalagopusJSON {
        value.map { .string($0) } ?? .null
    }
}
