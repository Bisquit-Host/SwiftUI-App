import SwiftUI
import Calagopus

struct NewTaskFields: View {
    @Binding var state: NewTaskState
    let backupGroups: [CalagopusServerBackupGroup]
    
    var body: some View {
        switch state.action {
        case .sleep:
            Section("Sleep") {
                TextField("Duration in milliseconds", text: $state.duration)
                    .keyboardType(.numberPad)
            }
            
        case .ensure:
            Section("Condition") {
                Text("No condition")
                    .secondary()
            }
            
        case .format:
            Section("Format") {
                TextField("Format string", text: $state.primaryValue)
                TextField("Output variable", text: $state.secondaryValue)
                    .textInputAutocapitalization(.never)
            }
            
        case .matchRegex:
            Section("Match regex") {
                TextField("Input", text: $state.primaryValue)
                TextField("Regex", text: $state.secondaryValue)
                
                TextField("Output variables", text: $state.listValue, axis: .vertical)
                    .lineLimit(3...)
                    .textInputAutocapitalization(.never)
            }
            
        case .waitForConsoleLine:
            Section("Console line") {
                TextField("Contains", text: $state.primaryValue)
                
                TextField("Output variable", text: $state.secondaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Timeout in milliseconds", text: $state.timeout)
                    .keyboardType(.numberPad)
                
                Toggle("Case insensitive", isOn: $state.caseInsensitive)
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
            
        case .sendPower, .power:
            Section("Power") {
                Picker("Action", selection: $state.powerAction) {
                    Text("Start").tag("start")
                    Text("Stop").tag("stop")
                    Text("Restart").tag("restart")
                    Text("Kill").tag("kill")
                }
                
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
            
        case .sendCommand, .command:
            Section("Command") {
                TextField("Command", text: $state.primaryValue, axis: .vertical)
                    .lineLimit(3...)
                
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
            
        case .createBackup, .backup:
            Section("Backup") {
                TextField("Backup name", text: $state.primaryValue)
                
                TextField("Ignored files", text: $state.listValue, axis: .vertical)
                    .lineLimit(3...)
                
                if !backupGroups.isEmpty {
                    Picker("Backup group", selection: $state.backupGroupID) {
                        Text("No group")
                            .tag(nil as String?)
                        
                        ForEach(backupGroups) {
                            Text($0.name)
                                .tag($0.uuid as String?)
                        }
                    }
                }
                
                Toggle("Run in foreground", isOn: $state.foreground)
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
            
        case .restoreBackup, .deleteBackup, .moveBackup:
            Section("Backup") {
                Picker("Select backup", selection: $state.backupSelectionMode) {
                    Text("Latest").tag("latest")
                    Text("Oldest").tag("oldest")
                    Text("UUID").tag("uuid")
                    Text("Name").tag("name")
                }
                
                if state.backupSelectionMode == "uuid" {
                    TextField("Backup UUID", text: $state.primaryValue)
                        .textInputAutocapitalization(.never)
                } else if state.backupSelectionMode == "name" {
                    TextField("Backup name", text: $state.primaryValue)
                    Toggle("Select oldest match", isOn: $state.selectOldestNamedBackup)
                }
                
                if state.backupSelectionMode != "uuid", !backupGroups.isEmpty {
                    Picker("Source group", selection: $state.backupGroupID) {
                        Text("Any group")
                            .tag(nil as String?)
                        
                        ForEach(backupGroups) {
                            Text($0.name)
                                .tag($0.uuid as String?)
                        }
                    }
                }
            }
            
            if state.action == .restoreBackup {
                Section("Restore") {
                    Toggle("Truncate directory", isOn: $state.truncateDirectory)
                    Toggle("Restore startup configuration", isOn: $state.restoreStartup)
                    Toggle("Ignore failure", isOn: $state.ignoreFailure)
                }
            } else if state.action == .moveBackup {
                Section("Destination") {
                    Picker("Backup group", selection: $state.targetBackupGroupID) {
                        Text("No group")
                            .tag(nil as String?)
                        
                        ForEach(backupGroups) {
                            Text($0.name)
                                .tag($0.uuid as String?)
                        }
                    }
                    
                    Toggle("Ignore failure", isOn: $state.ignoreFailure)
                }
            } else {
                Section {
                    Toggle("Ignore failure", isOn: $state.ignoreFailure)
                } footer: {
                    Text("Deleting a backup cannot be undone")
                }
            }
            
        case .createDirectory:
            Section("Directory") {
                TextField("Root path", text: $state.primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Name", text: $state.secondaryValue)
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
            
        case .writeFile:
            Section("File") {
                TextField("File path", text: $state.primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Content", text: $state.secondaryValue, axis: .vertical)
                    .lineLimit(3...)
                
                Toggle("Append", isOn: $state.append)
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
            
        case .copyFile:
            Section("Copy") {
                TextField("Source file", text: $state.primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Destination", text: $state.secondaryValue)
                    .textInputAutocapitalization(.never)
                
                Toggle("Run in foreground", isOn: $state.foreground)
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
        case .deleteFiles:
            Section("Delete") {
                TextField("Root path", text: $state.primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Files", text: $state.listValue, axis: .vertical)
                    .lineLimit(3...)
            }
            
        case .renameFiles:
            Section("Rename") {
                TextField("Root path", text: $state.primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Files as old=new", text: $state.listValue, axis: .vertical)
                    .lineLimit(3...)
            }
            
        case .compressFiles:
            Section("Compress") {
                TextField("Root path", text: $state.primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Archive name", text: $state.secondaryValue)
                
                TextField("Files", text: $state.listValue, axis: .vertical)
                    .lineLimit(3...)
                
                Picker("Format", selection: $state.archiveFormat) {
                    Text("tar.gz").tag("tar_gz")
                    Text("zip").tag("zip")
                }
                
                Toggle("Run in foreground", isOn: $state.foreground)
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
            
        case .decompressFile:
            Section("Decompress") {
                TextField("Root path", text: $state.primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("File", text: $state.secondaryValue)
                    .textInputAutocapitalization(.never)
                
                Toggle("Run in foreground", isOn: $state.foreground)
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
            
        case .updateStartupVariable:
            Section("Startup variable") {
                TextField("Environment variable", text: $state.primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Value", text: $state.secondaryValue)
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
            
        case .updateStartupCommand:
            Section("Startup command") {
                TextField("Command", text: $state.primaryValue, axis: .vertical)
                
                    .lineLimit(3...)
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
            
        case .updateStartupDockerImage:
            Section("Docker image") {
                TextField("Image", text: $state.primaryValue)
                
                    .textInputAutocapitalization(.never)
                Toggle("Ignore failure", isOn: $state.ignoreFailure)
            }
        }
    }
}
