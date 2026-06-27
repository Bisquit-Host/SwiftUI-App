import Calagopus

extension MinecraftInstalledProject {
    var installedVersionDisplayName: String? {
        trimmedDisplayValue(versionName) ?? trimmedDisplayValue(versionId)
    }
    
    var providerDisplayName: String? {
        trimmedDisplayValue(provider)
    }
    
    private func trimmedDisplayValue(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
