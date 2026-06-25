import SwiftUI
import Calagopus

struct NewTaskFields: View {
    let action: CalagopusScheduleTaskAction
    @Binding var duration: String
    @Binding var primaryValue: String
    @Binding var secondaryValue: String
    @Binding var tertiaryValue: String
    @Binding var listValue: String
    @Binding var powerAction: String
    @Binding var archiveFormat: String
    @Binding var ignoreFailure: Bool
    @Binding var foreground: Bool
    @Binding var append: Bool
    @Binding var caseInsensitive: Bool
    @Binding var timeout: String
    
    var body: some View {
        switch action {
        case .sleep:
            Section("Sleep") {
                TextField("Duration in milliseconds", text: $duration)
                    .keyboardType(.numberPad)
            }
            
        case .ensure:
            Section("Condition") {
                Text("No condition")
                    .secondary()
            }
            
        case .format:
            Section("Format") {
                TextField("Format string", text: $primaryValue)
                TextField("Output variable", text: $secondaryValue)
                    .textInputAutocapitalization(.never)
            }
            
        case .matchRegex:
            Section("Match regex") {
                TextField("Input", text: $primaryValue)
                TextField("Regex", text: $secondaryValue)
                
                TextField("Output variables", text: $listValue, axis: .vertical)
                    .lineLimit(3...)
                    .textInputAutocapitalization(.never)
            }
            
        case .waitForConsoleLine:
            Section("Console line") {
                TextField("Contains", text: $primaryValue)
                
                TextField("Output variable", text: $secondaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Timeout in milliseconds", text: $timeout)
                    .keyboardType(.numberPad)
                
                Toggle("Case insensitive", isOn: $caseInsensitive)
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
        
        case .sendPower, .power:
            Section("Power") {
                Picker("Action", selection: $powerAction) {
                    Text("Start").tag("start")
                    Text("Stop").tag("stop")
                    Text("Restart").tag("restart")
                    Text("Kill").tag("kill")
                }
                
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
        
        case .sendCommand, .command:
            Section("Command") {
                TextField("Command", text: $primaryValue, axis: .vertical)
                    .lineLimit(3...)
                
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
            
        case .createBackup, .backup:
            Section("Backup") {
                TextField("Backup name", text: $primaryValue)
                
                TextField("Ignored files", text: $listValue, axis: .vertical)
                    .lineLimit(3...)
                
                Toggle("Run in foreground", isOn: $foreground)
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
            
        case .createDirectory:
            Section("Directory") {
                TextField("Root path", text: $primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Name", text: $secondaryValue)
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
            
        case .writeFile:
            Section("File") {
                TextField("File path", text: $primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Content", text: $secondaryValue, axis: .vertical)
                    .lineLimit(3...)
                
                Toggle("Append", isOn: $append)
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
            
        case .copyFile:
            Section("Copy") {
                TextField("Source file", text: $primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Destination", text: $secondaryValue)
                    .textInputAutocapitalization(.never)
                
                Toggle("Run in foreground", isOn: $foreground)
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
        case .deleteFiles:
            Section("Delete") {
                TextField("Root path", text: $primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Files", text: $listValue, axis: .vertical)
                    .lineLimit(3...)
            }
            
        case .renameFiles:
            Section("Rename") {
                TextField("Root path", text: $primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Files as old=new", text: $listValue, axis: .vertical)
                    .lineLimit(3...)
            }
            
        case .compressFiles:
            Section("Compress") {
                TextField("Root path", text: $primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Archive name", text: $secondaryValue)
                
                TextField("Files", text: $listValue, axis: .vertical)
                    .lineLimit(3...)
                
                Picker("Format", selection: $archiveFormat) {
                    Text("tar.gz").tag("tar_gz")
                    Text("zip").tag("zip")
                }
                
                Toggle("Run in foreground", isOn: $foreground)
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
            
        case .decompressFile:
            Section("Decompress") {
                TextField("Root path", text: $primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("File", text: $secondaryValue)
                    .textInputAutocapitalization(.never)
                
                Toggle("Run in foreground", isOn: $foreground)
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
            
        case .updateStartupVariable:
            Section("Startup variable") {
                TextField("Environment variable", text: $primaryValue)
                    .textInputAutocapitalization(.never)
                
                TextField("Value", text: $secondaryValue)
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
            
        case .updateStartupCommand:
            Section("Startup command") {
                TextField("Command", text: $primaryValue, axis: .vertical)
                    
                    .lineLimit(3...)
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
            
        case .updateStartupDockerImage:
            Section("Docker image") {
                TextField("Image", text: $primaryValue)
                    
                    .textInputAutocapitalization(.never)
                Toggle("Ignore failure", isOn: $ignoreFailure)
            }
        }
    }
}
