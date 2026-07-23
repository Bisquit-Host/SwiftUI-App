import ScrechKit

@available(iOS 26, macOS 26, *)
struct ChatComposerModelPicker: View {
    @Binding private var selectedModel: String
    @Binding private var selectedReasoningEffort: String
    @Binding private var fastMode: String
    @Binding private var isOverlayOpen: Bool
    @AppStorage("big_ass_animations") private var bigAssAnimations = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sliderSelection: ModelLevel
    @State private var isSpeedModeEnabled: Bool
    @State private var openLabelFrame = CGRect.zero
    @State private var openPanelSize = CGSize.zero
    @State private var openSliderFrame = CGRect.zero
    @State private var openSpeedModeFrame = CGRect.zero
    @State private var pickerContainerSize = CGSize.zero
    private let modelOptions: [String]
    private let reasoningEffortOptions: [String]
    private let fastModeOptions: [String]
    private let preferencesLocked: Bool
    private let layout: ModelPickerLayout
    private let preferencesChanged: () -> Void
    
    init(
        selectedModel: Binding<String>,
        selectedReasoningEffort: Binding<String>,
        fastMode: Binding<String>,
        modelOptions: [String],
        reasoningEffortOptions: [String],
        fastModeOptions: [String],
        preferencesLocked: Bool,
        layout: ModelPickerLayout,
        isOverlayOpen: Binding<Bool>,
        preferencesChanged: @escaping () -> Void
    ) {
        _selectedModel = selectedModel
        _selectedReasoningEffort = selectedReasoningEffort
        _fastMode = fastMode
        _isOverlayOpen = isOverlayOpen
        _sliderSelection = State(initialValue: ModelLevel(reasoningEffort: selectedReasoningEffort.wrappedValue))
        _isSpeedModeEnabled = State(initialValue: fastMode.wrappedValue != "standard")
        self.modelOptions = modelOptions
        self.reasoningEffortOptions = reasoningEffortOptions
        self.fastModeOptions = fastModeOptions
        self.preferencesLocked = preferencesLocked
        self.layout = layout
        self.preferencesChanged = preferencesChanged
    }
    
    var body: some View {
        ZStack {
            if isOverlayOpen {
                OverlayDismissLayerView {
                    setOverlayOpen(false)
                }
            }
            
            VStack(spacing: 10) {
                HStack {
                    ModelLabelView(
                        modelTitle: modelTitle,
                        reasoningTitle: sliderSelection.title,
                        reservesReasoningWidth: true
                    )
                    .hidden()
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .named("Model picker"))
                    } action: {
                        openLabelFrame = $0
                    }
                    
                    Spacer()
                    
                    SpeedModeButtonView(
                        isEnabled: $isSpeedModeEnabled,
                        animationsEnabled: animationsEnabled
                    )
                    .disabled(preferencesLocked)
                    .hidden()
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .named("Model picker"))
                    } action: {
                        openSpeedModeFrame = $0
                    }
                }
                .padding(.leading, 52)
                .padding(.trailing, 32)
                
                ModelSliderView(
                    selection: $sliderSelection,
                    isFastModeEnabled: false,
                    particleFlowEnabled: false,
                    animationsEnabled: animationsEnabled,
                    selectionCommitted: { _ in }
                )
                .disabled(preferencesLocked)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
                .hidden()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .onGeometryChange(for: CGRect.self) {
                    $0.frame(in: .named("Model picker"))
                } action: {
                    openSliderFrame = $0
                }
            }
            .padding()
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGSize.self) {
                $0.size
            } action: {
                openPanelSize = $0
            }
#if !os(visionOS)
            .glassEffect(in: .rect(cornerRadius: 16))
#endif
            .padding(.horizontal)
            .position(
                x: pickerContainerSize.width / 2,
                y: openPanelCenterY + openOverlayOffset
            )
            .opacity(isOverlayOpen ? 1 : 0)
            .allowsHitTesting(isOverlayOpen)
            
            ModelLabelView(
                modelTitle: modelTitle,
                reasoningTitle: sliderSelection.title,
                reservesReasoningWidth: isOverlayOpen
            )
            .scaleEffect(isOverlayOpen ? 1.5 : 1)
            .position(
                x: (isOverlayOpen ? openLabelFrame : layout.labelFrame).midX,
                y: (isOverlayOpen ? openLabelFrame : layout.labelFrame).midY
                + openOverlayOffset
                + openContentCenteringOffset
            )
            .opacity(openLabelFrame == .zero || layout.labelFrame == .zero ? 0 : 1)
            .accessibilityHidden(true)
            
            ModelMenuView(
                selection: $selectedModel,
                options: modelOptions,
                reasoning: sliderSelection
            )
            .disabled(preferencesLocked)
            .scaleEffect(isOverlayOpen ? 1.5 : 1)
            .position(
                x: (isOverlayOpen ? openLabelFrame : layout.labelFrame).midX,
                y: (isOverlayOpen ? openLabelFrame : layout.labelFrame).midY
                + openOverlayOffset
                + openContentCenteringOffset
            )
            .opacity(0.001)
            .allowsHitTesting(
                isOverlayOpen && openLabelFrame != .zero && layout.labelFrame != .zero
            )
            
            ModelSliderView(
                selection: $sliderSelection,
                isFastModeEnabled: isSpeedModeEnabled,
                particleFlowEnabled: isOverlayOpen,
                animationsEnabled: animationsEnabled,
                selectionCommitted: commitReasoningEffort
            )
            .disabled(preferencesLocked)
            .padding(.horizontal)
            .frame(
                width: openSliderFrame.width,
                height: openSliderFrame.height
            )
            .scaleEffect(
                x: isOverlayOpen
                ? 1
                : layout.sliderFrame.width / max(openSliderFrame.width, 1),
                y: isOverlayOpen
                ? 1
                : layout.sliderFrame.height / max(openSliderFrame.height, 1)
            )
            .position(
                x: (isOverlayOpen ? openSliderFrame : layout.sliderFrame).midX,
                y: (isOverlayOpen ? openSliderFrame : layout.sliderFrame).midY
                + openOverlayOffset
                + openContentCenteringOffset
            )
            .opacity(isOverlayOpen ? 1 : 0)
            .opacity(openSliderFrame == .zero || layout.sliderFrame == .zero ? 0 : 1)
            .allowsHitTesting(isOverlayOpen)
            .hapticOn(sliderSelection, as: .impact(weight: .heavy))
            
            SpeedModeIconView(
                isEnabled: isSpeedModeEnabled,
                textStyle: .system(.title2, weight: .regular)
            )
            .frame(
                width: openSpeedModeFrame.width,
                height: openSpeedModeFrame.height
            )
            .scaleEffect(
                x: isOverlayOpen
                ? 1
                : layout.speedModeFrame.width / max(openSpeedModeFrame.width, 1),
                y: isOverlayOpen
                ? 1
                : layout.speedModeFrame.height / max(openSpeedModeFrame.height, 1)
            )
            .position(
                x: (isOverlayOpen ? openSpeedModeFrame : layout.speedModeFrame).midX,
                y: (isOverlayOpen ? openSpeedModeFrame : layout.speedModeFrame).midY
                + openOverlayOffset
                + openContentCenteringOffset
            )
            .opacity(openSpeedModeFrame == .zero || layout.speedModeFrame == .zero ? 0 : 1)
            .opacity(isOverlayOpen || isSpeedModeEnabled ? 1 : 0)
            .accessibilityHidden(isOverlayOpen || !isSpeedModeEnabled)
            
            SpeedModeButtonView(
                isEnabled: $isSpeedModeEnabled,
                animationsEnabled: animationsEnabled
            )
            .disabled(preferencesLocked)
            .frame(
                width: openSpeedModeFrame.width,
                height: openSpeedModeFrame.height
            )
            .position(
                x: openSpeedModeFrame.midX,
                y: openSpeedModeFrame.midY + openOverlayOffset + openContentCenteringOffset
            )
            .opacity(0.001)
            .allowsHitTesting(isOverlayOpen)
            .hapticOn(isSpeedModeEnabled, as: .impact(weight: .medium))
            .accessibilityHidden(!isOverlayOpen)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGSize.self) {
            $0.size
        } action: {
            pickerContainerSize = $0
        }
        .coordinateSpace(.named("Model picker"))
        .allowsHitTesting(isOverlayOpen)
        .onChange(of: selectedModel) {
            preferencesChanged()
        }
        .onChange(of: selectedReasoningEffort) {
            sliderSelection = ModelLevel(reasoningEffort: selectedReasoningEffort)
            preferencesChanged()
        }
        .onChange(of: fastMode) {
            isSpeedModeEnabled = fastMode != "standard"
            preferencesChanged()
        }
        .onChange(of: isSpeedModeEnabled) {
            fastMode = isSpeedModeEnabled ? enabledFastMode : "standard"
        }
    }
    
    private var animationsEnabled: Bool {
        bigAssAnimations && !reduceMotion
    }
    
    private var modelTitle: String {
        CodexModelNameFormatter.title(for: selectedModel)
    }
    
    private var enabledFastMode: String {
        fastModeOptions.first { $0 != "standard" } ?? "fast"
    }
    
    private var openPanelCenterY: CGFloat {
        max(openPanelSize.height / 2, layout.composerFrame.midY)
    }
    
    private var openOverlayOffset: CGFloat {
        isOverlayOpen ? -20 : 0
    }
    
    private var openContentCenteringOffset: CGFloat {
        isOverlayOpen ? 15 : 0
    }
    
    private func reasoningEffort(for level: ModelLevel) -> String {
        reasoningEffortOptions.first {
            ModelLevel(reasoningEffort: $0) == level
        } ?? level.reasoningEffort
    }
    
    private func commitReasoningEffort(_ level: ModelLevel) {
        selectedReasoningEffort = reasoningEffort(for: level)
    }
    
    private func setOverlayOpen(_ isOpen: Bool) {
        guard animationsEnabled else {
            isOverlayOpen = isOpen
            return
        }
        
        withAnimation(.default.speed(1.5)) {
            isOverlayOpen = isOpen
        }
    }
}

#Preview {
    ChatComposerModelPicker(
        selectedModel: .constant("gpt-5"),
        selectedReasoningEffort: .constant("medium"),
        fastMode: .constant("standard"),
        modelOptions: ["gpt-5"],
        reasoningEffortOptions: ["light", "medium", "high", "xhigh"],
        fastModeOptions: ["standard", "fast"],
        preferencesLocked: false,
        layout: ModelPickerLayout(
            labelFrame: CGRect(x: 200, y: 600, width: 100, height: 30),
            sliderFrame: CGRect(x: 250, y: 615, width: 1, height: 1),
            speedModeFrame: CGRect(x: 304, y: 600, width: 30, height: 30)
        ),
        isOverlayOpen: .constant(false),
        preferencesChanged: {}
    )
    .frame(width: 390, height: 700)
    .darkSchemePreferred()
}
