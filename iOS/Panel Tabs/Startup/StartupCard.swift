import ScrechKit
import AlertKit
import Calagopus

struct StartupCard: View {
    @Environment(StartupVM.self) private var vm
    
    private let variable: CalagopusServerVariable
    
    init(_ server: CalagopusServer, variable: CalagopusServerVariable) {
        self.variable = variable
        
        let currentValue = Self.currentValue(for: variable)
        _value = State(initialValue: currentValue)
        _savedValue = State(initialValue: currentValue)
        _boolValue = State(initialValue: Self.booleanValue(for: currentValue))
    }
    
    @State private var value = ""
    @State private var savedValue = ""
    @State private var boolValue = false
    @State private var isUpdatingValue = false
    @State private var isUpdatingBool = false
    
    private var isBooleanVariable: Bool {
        variable.rules.joined(separator: "|").localizedStandardContains("boolean")
    }
    
    private var enumOptions: [String] {
        Self.enumOptions(from: variable.rules)
    }
    
    private var isEnumVariable: Bool {
        !enumOptions.isEmpty
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack {
                    if isBooleanVariable {
                        Toggle(variable.name, isOn: $boolValue)
                            .disabled(!variable.isEditable)
                            .onChange(of: boolValue) { _, newValue in
                                guard !isUpdatingBool else {
                                    return
                                }
                                
                                updateBooleanValue(newValue)
                            }
                    } else {
                        Text(variable.name)
                        
                        Spacer()
                    }
                    
                    if variable.isEditable {
                        Menu {
                            Button("Reset to default", systemImage: "arrow.counterclockwise") {
                                setValue(variable.defaultValue ?? "")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .semibold()
                                .foregroundStyle(.foreground)
                        }
                        .padding(.leading) // avoids collision with name
                    }
                }
                
                Text(variable.description ?? "")
                    .caption2()
                    .secondary()
                    .padding(.top, 4)
                
                if !isBooleanVariable {
                    if isEnumVariable {
                        Picker("", selection: $value) {
                            ForEach(enumOptionsWithCurrentValue, id: \.self) {
                                Text($0)
                                    .tag($0)
                            }
                        }
                        .tint(.primary)
                        .pickerStyle(.menu)
                        .disabled(!variable.isEditable)
                    } else {
                        TextField("Type here", text: $value)
                            .autocorrectionDisabled()
                            .disabled(!variable.isEditable)
                    }
                }
            }
        }
        .onChange(of: value) { _, newValue in
            guard !isBooleanVariable, !isUpdatingValue else {
                return
            }
            
            updateValue(newValue)
        }
        .onChange(of: variable.value) { _, newValue in
            setValue(newValue)
            savedValue = newValue
        }
    }
    
    private var enumOptionsWithCurrentValue: [String] {
        let currentValue = value.isEmpty ? variable.value : value
        if enumOptions.contains(currentValue) {
            return enumOptions
        }
        
        return [currentValue] + enumOptions
    }
    
    private func updateValue(_ newValue: String) {
        guard variable.isEditable else {
            return
        }
        
        let currentServerValue = savedValue
        guard newValue != currentServerValue else {
            return
        }
        
        Task {
            await vm.updateVariable(key: variable.envVariable, value: newValue, onSuccess: { attributes in
                SystemAlert.done(String(localized: "\(attributes.name) updated"))
                savedValue = attributes.value
                setValue(attributes.value)
            }) {
                setValue(currentServerValue)
            }
        }
    }
    
    private func updateBooleanValue(_ newValue: Bool) {
        let newValueString = Self.booleanString(for: newValue, template: variable.value)
        value = newValueString
        
        Task {
            await vm.updateVariable(key: variable.envVariable, value: newValueString, onSuccess: { attributes in
                SystemAlert.done(newValue ? String(localized: "\(attributes.name) enabled") : String(localized: "\(attributes.name) disabled"))
                savedValue = attributes.value
                setValue(attributes.value)
            }) {
                setValue(savedValue)
            }
        }
    }
    
    private func setValue(_ newValue: String) {
        isUpdatingValue = true
        value = newValue
        isUpdatingValue = false
        
        if isBooleanVariable {
            isUpdatingBool = true
            boolValue = Self.booleanValue(for: newValue)
            isUpdatingBool = false
        }
    }
    
    private static func booleanValue(for value: String) -> Bool {
        value.lowercased() == "1"
    }
    
    private static func currentValue(for variable: CalagopusServerVariable) -> String {
        variable.value
    }
    
    private static func booleanString(for value: Bool, template: String) -> String {
        let trimmed = template.trimmingCharacters(in: .whitespacesAndNewlines)
        let usesNumeric = Int(trimmed) != nil
        
        return usesNumeric ? (value ? "1" : "0") : (value ? "true" : "false")
    }
    
    private static func enumOptions(from rules: [String]) -> [String] {
        for component in rules {
            let trimmed = component.trimmingCharacters(in: .whitespacesAndNewlines)
            let lowercased = trimmed.lowercased()
            
            if lowercased.hasPrefix("in:") {
                return Self.parseEnumOptions(from: trimmed.dropFirst(3))
            }
            
            if lowercased.hasPrefix("enum:") {
                return Self.parseEnumOptions(from: trimmed.dropFirst(5))
            }
        }
        
        return []
    }
    
    private static func parseEnumOptions(from rawValue: Substring) -> [String] {
        rawValue
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
