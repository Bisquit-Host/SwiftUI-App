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
    @State private var duration = "0"
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
    
    private var newTask: CalagopusScheduleTaskCreate {
        .init(action: actionPayload)
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
            .object(["type": .string(action.scheduleType), "format": .string(primaryValue), "outputInto": .object(["variable": .string(secondaryValue)])])
        case .matchRegex:
            .object(["type": .string(action.scheduleType), "input": .string(primaryValue), "regex": .string(secondaryValue), "outputInto": .array(files.map { .object(["variable": $0]) })])
        case .waitForConsoleLine:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "contains": .string(primaryValue), "caseInsensitive": .bool(caseInsensitive), "timeout": .number(Double(timeout) ?? 0), "outputInto": outputInto])
        case .sendPower, .power:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "action": .string(powerAction)])
        case .sendCommand, .command:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "command": .string(primaryValue)])
        case .createBackup, .backup:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "foreground": .bool(foreground), "name": optionalString(primaryValue), "ignoredFiles": .array(files)])
        case .createDirectory:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "root": .string(primaryValue), "name": .string(secondaryValue)])
        case .writeFile:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "append": .bool(append), "file": .string(primaryValue), "content": .string(secondaryValue)])
        case .copyFile:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "foreground": .bool(foreground), "file": .string(primaryValue), "destination": .string(secondaryValue)])
        case .deleteFiles:
            .object(["type": .string(action.scheduleType), "root": .string(primaryValue), "files": .array(files)])
        case .renameFiles:
            .object(["type": .string(action.scheduleType), "root": .string(primaryValue), "files": .array(renameFiles)])
        case .compressFiles:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "foreground": .bool(foreground), "root": .string(primaryValue), "files": .array(files), "format": .string(archiveFormat), "name": .string(secondaryValue)])
        case .decompressFile:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "foreground": .bool(foreground), "root": .string(primaryValue), "file": .string(secondaryValue)])
        case .updateStartupVariable:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "envVariable": .string(primaryValue), "value": .string(secondaryValue)])
        case .updateStartupCommand:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "command": .string(primaryValue)])
        case .updateStartupDockerImage:
            .object(["type": .string(action.scheduleType), "ignoreFailure": .bool(ignoreFailure), "image": .string(primaryValue)])
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
                timeout: $timeout
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
#if os(tvOS)
                .buttonStyle(.borderedProminent)
#endif
            }
        }
    }
    
    private func optionalString(_ value: String) -> CalagopusJSON {
        value.isEmpty ? .null : .string(value)
    }
}

#Preview {
    NewTaskSheet("")
        .darkSchemePreferred()
        .environment(ScheduleVM(""))
}
