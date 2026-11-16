import ScrechKit

struct AgentQuestionOptionRow: View {
    let option: AgentQuestionOption
    let multiSelect: Bool
    @Binding var answer: AgentQuestionAnswer
    
    private var isSelected: Bool {
        answer.selected.contains(option.label)
    }
    
    private var systemImage: String {
        if multiSelect {
            isSelected ? "checkmark.square.fill" : "square"
        } else {
            isSelected ? "largecircle.fill.circle" : "circle"
        }
    }
    
    var body: some View {
        Button(action: toggle) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: systemImage)
                    .foregroundStyle(isSelected ? .orange : .secondary)
                
                VStack(alignment: .leading) {
                    Text(option.label)
                        .foregroundStyle(.foreground)
                    
                    if !option.description.isEmpty {
                        Text(option.description)
                            .footnote()
                            .secondary()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private func toggle() {
        if multiSelect {
            if isSelected {
                answer.selected.removeAll { $0 == option.label }
            } else {
                answer.selected.append(option.label)
            }
        } else {
            answer.selected = isSelected ? [] : [option.label]
        }
    }
}
