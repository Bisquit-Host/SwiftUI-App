import SwiftUI
import Calagopus

struct NewTaskSheet: View {
    @Environment(ScheduleVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let scheudleId: String
    
    init(_ scheudleId: String) {
        self.scheudleId = scheudleId
    }
    
    @State private var action: CalagopusScheduleTaskAction = .sleep
    @State private var duration = "1000"
    @State private var primaryValue = ""
    @State private var secondaryValue = ""
    @State private var tertiaryValue = ""
    @State private var listValue = ""
    @State private var powerAction = "start"
    @State private var archiveFormat = "tar_gz"
    @State private var ignoreFailure = false
    @State private var foreground = false
    @State private var append = false
    @State private var caseInsensitive = false
    @State private var timeout = "5000"
    @State private var backupSelectionMode = "latest"
    @State private var backupGroupID: String?
    @State private var targetBackupGroupID: String?
    @State private var selectOldestNamedBackup = false
    @State private var truncateDirectory = false
    @State private var restoreStartup = false
    
    private var newTask: CalagopusScheduleTaskCreate {
        .init(order: vm.nextStepOrder(for: scheudleId), action: actionPayload)
    }
    
    private var files: [CalagopusJSON] {
        listValue
            .split(whereSeparator: \.isNewline)
            .map { .string(String($0)) }
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
    
    var body: some View {
        List {
            Section("Action") {
                Picker("Action", selection: $action) {
                    ForEach(CalagopusScheduleTaskAction.panelCases) {
                        Label($0.taskLabel, systemImage: $0.taskIcon)
                            .tag($0)
                    }
                }
            }
            
            NewTaskFields(
                action: action,
                backupGroups: vm.backupGroups,
                duration: $duration,
                primaryValue: $primaryValue,
                secondaryValue: $secondaryValue,
                tertiaryValue: $tertiaryValue,
                listValue: $listValue,
                powerAction: $powerAction,
                archiveFormat: $archiveFormat,
                ignoreFailure: $ignoreFailure,
                foreground: $foreground,
                append: $append,
                caseInsensitive: $caseInsensitive,
                timeout: $timeout,
                backupSelectionMode: $backupSelectionMode,
                backupGroupID: $backupGroupID,
                targetBackupGroupID: $targetBackupGroupID,
                selectOldestNamedBackup: $selectOldestNamedBackup,
                truncateDirectory: $truncateDirectory,
                restoreStartup: $restoreStartup
            )
            
#if os(tvOS)
            Divider()
#endif
            Section {
                Button("Create Task") {
                    Task {
                        await vm.createScheduleTask(scheudleId, newTask: newTask) {
                            dismiss()
                        }
                    }
                }
                .disabled(!hasValidActionInput)
#if os(tvOS)
                .buttonStyle(.borderedProminent)
#endif
            }
        }
        .task {
            await vm.fetchBackupGroupsIfNeeded()
        }
    }
    
    private func optionalString(_ value: String) -> CalagopusJSON {
        value.isEmpty ? .null : .string(value)
    }

    private func optionalString(_ value: String?) -> CalagopusJSON {
        value.map { .string($0) } ?? .null
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

    private var hasValidActionInput: Bool {
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
}

#Preview {
    NewTaskSheet("")
        .darkSchemePreferred()
        .environment(ScheduleVM(""))
}
