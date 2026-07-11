import Foundation

enum CodexModelNameFormatter {
    static func title(for model: String) -> String {
        let components = model.split(separator: "-", maxSplits: 2)

        guard components.count >= 2, components[0] == "gpt" else {
            return model
        }

        guard components.count == 3 else {
            return String(components[1])
        }

        return "\(components[1]) \(components[2].capitalized)"
    }
}
