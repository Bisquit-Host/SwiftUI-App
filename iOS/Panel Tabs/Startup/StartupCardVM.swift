import ScrechKit
import Calagopus

@Observable
final class StartupCardVM {
    private var variable: CalagopusServerVariable
    private(set) var savedValue: String
    private(set) var isSaving = false

    var value: String {
        didSet {
            boolValue = StartupVariableParser.booleanValue(value)
        }
    }

    var boolValue: Bool {
        didSet {
            guard boolValue != StartupVariableParser.booleanValue(value) else { return }
            value = StartupVariableParser.booleanString(boolValue, template: savedValue)
        }
    }

    init(_ variable: CalagopusServerVariable) {
        self.variable = variable
        value = variable.value
        savedValue = variable.value
        boolValue = StartupVariableParser.booleanValue(variable.value)
    }

    var isBooleanVariable: Bool {
        StartupVariableParser.isBoolean(variable.rules)
    }

    var isEnumVariable: Bool {
        !StartupVariableParser.enumOptions(variable.rules).isEmpty
    }

    var enumOptionsWithCurrentValue: [String] {
        let options = StartupVariableParser.enumOptions(variable.rules)
        return options.contains(value) ? options : [value] + options
    }

    func reset(to defaultValue: String) {
        guard variable.isEditable else { return }
        value = defaultValue
    }

    func synchronize(_ variable: CalagopusServerVariable) {
        self.variable = variable
        guard !isSaving else { return }
        savedValue = variable.value
        value = variable.value
    }

    func save(using update: (String, String) async -> CalagopusServerVariable?) async {
        guard variable.isEditable, !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        while value != savedValue {
            let submittedValue = value
            let updated = await update(variable.envVariable, submittedValue)

            if let updated {
                savedValue = updated.value
                variable = updated
                if isBooleanVariable {
                    SystemAlert.done(StartupVariableParser.booleanValue(updated.value)
                        ? String(localized: "\(updated.name) enabled")
                        : String(localized: "\(updated.name) disabled"))
                } else {
                    SystemAlert.done(String(localized: "\(updated.name) updated"))
                }
            }

            if value == submittedValue {
                value = savedValue
            }
        }
    }
}
