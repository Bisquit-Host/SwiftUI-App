import Foundation

enum StartupVariableParser {
    static func booleanValue(_ value: String) -> Bool {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized == "1" || normalized == "true"
    }

    static func booleanString(_ value: Bool, template: String) -> String {
        let trimmed = template.trimmingCharacters(in: .whitespacesAndNewlines)
        return Int(trimmed) != nil ? (value ? "1" : "0") : (value ? "true" : "false")
    }

    static func isBoolean(_ rules: [String]) -> Bool {
        rules.contains {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "boolean"
        }
    }

    static func enumOptions(_ rules: [String]) -> [String] {
        for rule in rules {
            let trimmed = rule.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalized = trimmed.lowercased()
            let prefixLength: Int
            if normalized.hasPrefix("in:") {
                prefixLength = 3
            } else if normalized.hasPrefix("enum:") {
                prefixLength = 5
            } else {
                continue
            }

            return trimmed.dropFirst(prefixLength)
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        return []
    }
}
