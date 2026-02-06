import ScrechKit
import AlertKit
import PteroNet

struct StartupCard: View {
    private var vm: StartupVM
    private let server: ServerAttributes
    private let variable: StartupVariable
    
    init(_ server: ServerAttributes, variable: StartupVariable) {
        self.server = server
        self.variable = variable
        vm = StartupVM(server.id)
        
        let currentValue = Self.currentValue(for: variable)
        _value = State(initialValue: currentValue)
        _boolValue = State(initialValue: Self.booleanValue(for: currentValue))
    }
    
    @State private var value = ""
    @State private var boolValue = false
    @State private var isUpdatingValue = false
    @State private var isUpdatingBool = false
    
    private var isBooleanVariable: Bool {
        variable.rules.lowercased().contains("boolean")
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
                                setValue(variable.defaultValue)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .semibold()
                                .foregroundStyle(.foreground)
                        }
                    }
                }
                
                Text(variable.description)
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
        .onChange(of: variable.serverValue) { _, newValue in
            setValue(newValue ?? variable.defaultValue)
        }
    }
    
    private var enumOptionsWithCurrentValue: [String] {
        let currentValue = value.isEmpty ? variable.serverValue ?? variable.defaultValue : value
        if enumOptions.contains(currentValue) {
            return enumOptions
        }
        
        return [currentValue] + enumOptions
    }
    
    private func updateValue(_ newValue: String) {
        guard variable.isEditable else {
            return
        }
        
        let currentServerValue = variable.serverValue ?? variable.defaultValue
        guard newValue != currentServerValue else {
            return
        }
        
        Task {
            await vm.updateVariable(key: variable.envVariable, value: newValue, onSuccess: { attributes in
                SystemAlert.done("\(attributes.name) updated")
                setValue(attributes.serverValue ?? attributes.defaultValue)
            }) {
                setValue(currentServerValue)
            }
        }
    }
    
    private func updateBooleanValue(_ newValue: Bool) {
        let newValueString = Self.booleanString(for: newValue, template: variable.serverValue ?? variable.defaultValue)
        value = newValueString
        
        Task {
            await vm.updateVariable(key: variable.envVariable, value: newValueString, onSuccess: { attributes in
                SystemAlert.done(newValue ? "\(attributes.name) enabled" : "\(attributes.name) disabled")
                setValue(attributes.serverValue ?? attributes.defaultValue)
            }) {
                setValue(variable.serverValue ?? "")
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
    
    private static func currentValue(for variable: StartupVariable) -> String {
        variable.serverValue ?? variable.defaultValue
    }
    
    private static func booleanString(for value: Bool, template: String) -> String {
        let trimmed = template.trimmingCharacters(in: .whitespacesAndNewlines)
        let usesNumeric = Int(trimmed) != nil
        
        return usesNumeric ? (value ? "1" : "0") : (value ? "true" : "false")
    }
    
    private static func enumOptions(from rules: String) -> [String] {
        let components = rules.split(separator: "|")
        
        for component in components {
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

//#Preview {
//    List {
//        StartupCard(
//            PreviewProp.serverAttributes,
//            variable: StartupVariable(
//                name: "Variable Name",
//                description: "Some variable does something",
//                envVariable: "SOME_VARIABLE",
//                defaultValue: "Default Value",
//                serverValue: "Current Value",
//                rules: "",
//                isEditable: true
//            )
//        )
//    }
//    .darkSchemePreferred()
//}
