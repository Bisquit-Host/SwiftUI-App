import ScrechKit

struct ModelMenuView: View {
    @Binding var selection: String
    let options: [String]
    let reasoning: ModelLevel
    let isSpeedModeEnabled: Bool?

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { model in
                if selection == model {
                    Button(modelTitle(model), systemImage: "checkmark") {
                        selection = model
                    }
                } else {
                    Button(modelTitle(model)) {
                        selection = model
                    }
                }
            }
        } label: {
            ModelLabelView(
                modelTitle: modelTitle(selection),
                reasoningTitle: reasoning.title,
                reservesReasoningWidth: true,
                isSpeedModeEnabled: isSpeedModeEnabled
            )
        }
        .menuIndicator(.hidden)
    }

    private func modelTitle(_ model: String) -> String {
        CodexModelNameFormatter.title(for: model)
    }
}
