import Foundation

nonisolated enum VersionChangerBuildVersionFormatter {
    static func installedVersion(for build: VersionChangerBuild) -> String {
        firstNonEmpty(build.versionId, build.projectVersionId) ?? "unknown"
    }
    
    static func installedBuild(for build: VersionChangerBuild) -> String {
        firstNonEmpty(build.name, build.projectVersionId) ?? "unknown"
    }
    
    static func displayVersion(for build: VersionChangerBuild) -> String {
        let parts = uniqueNonEmptyParts(
            build.versionId,
            build.projectVersionId,
            build.name
        )
        
        guard parts.isEmpty == false else {
            return "Version unknown"
        }
        
        return "Version \(parts.joined(separator: " "))"
    }
    
    private static func firstNonEmpty(_ values: String?...) -> String? {
        values
            .compactMap {
                $0?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .first {
                $0.isEmpty == false
            }
    }
    
    private static func uniqueNonEmptyParts(_ values: String?...) -> [String] {
        var parts = [String]()
        
        for value in values {
            guard let part = value?.trimmingCharacters(in: .whitespacesAndNewlines),
                  part.isEmpty == false,
                  parts.contains(where: { $0.caseInsensitiveCompare(part) == .orderedSame }) == false else {
                continue
            }
            
            parts.append(part)
        }
        
        return parts
    }
}
