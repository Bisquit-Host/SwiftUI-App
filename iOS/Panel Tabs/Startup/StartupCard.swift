import ScrechKit
import Calagopus

struct StartupCard: View {
    @Environment(StartupVM.self) private var vm
    @State private var cardVM: StartupCardVM
    
    private let variable: CalagopusServerVariable
    
    init(_ server: CalagopusServer, variable: CalagopusServerVariable) {
        self.variable = variable
        _cardVM = State(initialValue: StartupCardVM(variable))
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack {
                    if cardVM.isBooleanVariable {
                        Toggle(variable.name, isOn: $cardVM.boolValue)
                            .disabled(!variable.isEditable)
                    } else {
                        Text(variable.name)
                        
                        Spacer()
                    }
                    
                    if variable.isEditable {
                        Menu {
                            Button("Reset to default", systemImage: "arrow.counterclockwise") {
                                cardVM.reset(to: variable.defaultValue ?? "")
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
                
                if !cardVM.isBooleanVariable {
                    if cardVM.isEnumVariable {
                        Picker("", selection: $cardVM.value) {
                            ForEach(cardVM.enumOptionsWithCurrentValue, id: \.self) {
                                Text($0)
                                    .tag($0)
                            }
                        }
                        .tint(.primary)
                        .pickerStyle(.menu)
                        .disabled(!variable.isEditable)
                    } else {
                        TextField("Type here", text: $cardVM.value)
                            .autocorrectionDisabled()
                            .disabled(!variable.isEditable)
                    }
                }
            }
        }
        .onChange(of: cardVM.value) {
            Task {
                await cardVM.save(using: vm.updateVariable)
            }
        }
        .onChange(of: variable.value) {
            cardVM.synchronize(variable)
        }
    }
}
