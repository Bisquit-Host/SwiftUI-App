import ScrechKit

struct ChatComposerModelPickerAnchor: View {
    @Environment(AgentChatVM.self) private var vm
    @Binding var presentation: ChatComposerPresentationState
    @AppStorage("big_ass_animations") private var bigAssAnimations = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var openHaptic = 0

    var body: some View {
        Button {
            openHaptic += 1
            setPresented()
        } label: {
            HStack(spacing: 4) {
                ZStack(alignment: .trailing) {
                    ForEach(ModelLevel.allCases, id: \.self) { level in
                        ModelLabelView(
                            modelTitle: modelTitle,
                            reasoningTitle: level.title
                        )
                        .hidden()
                    }

                    ModelLabelView(
                        modelTitle: modelTitle,
                        reasoningTitle: reasoningTitle
                    )
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .named("Agent chat"))
                    } action: {
                        presentation.labelFrame = $0
                    }
                }

                SpeedModeIconView(
                    isEnabled: vm.fastMode != "standard",
                    textStyle: .callout
                )
                .onGeometryChange(for: CGRect.self) {
                    $0.frame(in: .named("Agent chat"))
                } action: {
                    presentation.speedModeFrame = $0
                }
            }
        }
        .buttonStyle(.plain)
        .opacity(0.001)
        .hapticOn(openHaptic, as: .impact(weight: .light))
        .background {
            Color.clear
                .frame(width: 1, height: 1)
                .onGeometryChange(for: CGRect.self) {
                    $0.frame(in: .named("Agent chat"))
                } action: {
                    presentation.sliderFrame = $0
                }
        }
    }

    private var modelTitle: String {
        CodexModelNameFormatter.title(for: vm.codexModel)
    }

    private var reasoningTitle: String {
        ModelLevel(reasoningEffort: vm.codexReasoningEffort).title
    }

    private func setPresented() {
        guard bigAssAnimations, !reduceMotion else {
            presentation.isModelPickerPresented = true
            return
        }

        withAnimation(.default.speed(1.5)) {
            presentation.isModelPickerPresented = true
        }
    }
}
