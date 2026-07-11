import ScrechKit

struct ChatComposerModelPickerAnchor: View {
    @Binding private var layout: ModelPickerLayout
    @Binding private var isPresented: Bool
    @AppStorage("big_ass_animations") private var bigAssAnimations = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var openHaptic = 0
    private let selectedModel: String
    private let selectedReasoningEffort: String
    private let fastMode: String

    init(
        selectedModel: String,
        selectedReasoningEffort: String,
        fastMode: String,
        layout: Binding<ModelPickerLayout>,
        isPresented: Binding<Bool>
    ) {
        self.selectedModel = selectedModel
        self.selectedReasoningEffort = selectedReasoningEffort
        self.fastMode = fastMode
        _layout = layout
        _isPresented = isPresented
    }

    var body: some View {
        Button {
            openHaptic += 1
            setPresented()
        } label: {
            HStack(spacing: -8) {
                ZStack(alignment: .leading) {
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
                        $0.frame(in: .named("Codex chat"))
                    } action: {
                        layout.labelFrame = $0
                    }
                }

                SpeedModeIconView(
                    isEnabled: fastMode != "standard",
                    textStyle: .callout
                )
                .onGeometryChange(for: CGRect.self) {
                    $0.frame(in: .named("Codex chat"))
                } action: {
                    layout.speedModeFrame = $0
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
                    $0.frame(in: .named("Codex chat"))
                } action: {
                    layout.sliderFrame = $0
                }
        }
    }

    private var modelTitle: String {
        selectedModel.replacing("gpt-", with: "")
    }

    private var reasoningTitle: String {
        ModelLevel(reasoningEffort: selectedReasoningEffort).title
    }

    private func setPresented() {
        guard bigAssAnimations, !reduceMotion else {
            isPresented = true
            return
        }

        withAnimation(.default.speed(1.5)) {
            isPresented = true
        }
    }
}
