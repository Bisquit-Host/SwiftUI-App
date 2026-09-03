import ScrechKit

struct ChatComposerModelPicker: View {
    @Environment(CodexChatVM.self) private var vm
    @Binding var presentation: ChatComposerPresentationState
    @AppStorage("big_ass_animations") private var bigAssAnimations = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sliderSelection = ModelLevel.medium
    @State private var isSpeedModeEnabled = false
    @State private var openLabelFrame = CGRect.zero
    @State private var openPanelSize = CGSize.zero
    @State private var openSliderFrame = CGRect.zero
    @State private var openSpeedModeFrame = CGRect.zero
    @State private var pickerContainerSize = CGSize.zero
    
    var body: some View {
        @Bindable var vm = vm

        ZStack {
            if presentation.isModelPickerPresented {
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
            .opacity(presentation.isModelPickerPresented ? 1 : 0)
            .allowsHitTesting(presentation.isModelPickerPresented)
            
            ModelLabelView(
                modelTitle: modelTitle,
                reasoningTitle: sliderSelection.title,
                reservesReasoningWidth: presentation.isModelPickerPresented
            )
            .scaleEffect(presentation.isModelPickerPresented ? 1.5 : 1)
            .position(
                x: (presentation.isModelPickerPresented ? openLabelFrame : presentation.labelFrame).midX,
                y: (presentation.isModelPickerPresented ? openLabelFrame : presentation.labelFrame).midY
                + openOverlayOffset
                + openContentCenteringOffset
            )
            .opacity(openLabelFrame == .zero || presentation.labelFrame == .zero ? 0 : 1)
            .accessibilityHidden(true)
            
            ModelMenuView(
                selection: $vm.codexModel,
                options: vm.codexModelOptions,
                reasoning: sliderSelection
            )
            .disabled(preferencesLocked)
            .scaleEffect(presentation.isModelPickerPresented ? 1.5 : 1)
            .position(
                x: (presentation.isModelPickerPresented ? openLabelFrame : presentation.labelFrame).midX,
                y: (presentation.isModelPickerPresented ? openLabelFrame : presentation.labelFrame).midY
                + openOverlayOffset
                + openContentCenteringOffset
            )
            .opacity(0.001)
            .allowsHitTesting(
                presentation.isModelPickerPresented
                && openLabelFrame != .zero
                && presentation.labelFrame != .zero
            )
            
            ModelSliderView(
                selection: $sliderSelection,
                isFastModeEnabled: isSpeedModeEnabled,
                particleFlowEnabled: presentation.isModelPickerPresented,
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
                x: presentation.isModelPickerPresented
                ? 1
                : presentation.sliderFrame.width / max(openSliderFrame.width, 1),
                y: presentation.isModelPickerPresented
                ? 1
                : presentation.sliderFrame.height / max(openSliderFrame.height, 1)
            )
            .position(
                x: (presentation.isModelPickerPresented ? openSliderFrame : presentation.sliderFrame).midX,
                y: (presentation.isModelPickerPresented ? openSliderFrame : presentation.sliderFrame).midY
                + openOverlayOffset
                + openContentCenteringOffset
            )
            .opacity(presentation.isModelPickerPresented ? 1 : 0)
            .opacity(openSliderFrame == .zero || presentation.sliderFrame == .zero ? 0 : 1)
            .allowsHitTesting(presentation.isModelPickerPresented)
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
                x: presentation.isModelPickerPresented
                ? 1
                : presentation.speedModeFrame.width / max(openSpeedModeFrame.width, 1),
                y: presentation.isModelPickerPresented
                ? 1
                : presentation.speedModeFrame.height / max(openSpeedModeFrame.height, 1)
            )
            .position(
                x: (presentation.isModelPickerPresented ? openSpeedModeFrame : presentation.speedModeFrame).midX,
                y: (presentation.isModelPickerPresented ? openSpeedModeFrame : presentation.speedModeFrame).midY
                + openOverlayOffset
                + openContentCenteringOffset
            )
            .opacity(openSpeedModeFrame == .zero || presentation.speedModeFrame == .zero ? 0 : 1)
            .opacity(presentation.isModelPickerPresented || isSpeedModeEnabled ? 1 : 0)
            .accessibilityHidden(presentation.isModelPickerPresented || !isSpeedModeEnabled)
            
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
            .allowsHitTesting(presentation.isModelPickerPresented)
            .hapticOn(isSpeedModeEnabled, as: .impact(weight: .medium))
            .accessibilityHidden(!presentation.isModelPickerPresented)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGSize.self) {
            $0.size
        } action: {
            pickerContainerSize = $0
        }
        .coordinateSpace(.named("Model picker"))
        .allowsHitTesting(presentation.isModelPickerPresented)
        .onAppear {
            sliderSelection = ModelLevel(reasoningEffort: vm.codexReasoningEffort)
            isSpeedModeEnabled = vm.fastMode != "standard"
        }
        .onChange(of: vm.codexModel) {
            updatePreferences()
        }
        .onChange(of: vm.codexReasoningEffort) {
            sliderSelection = ModelLevel(reasoningEffort: vm.codexReasoningEffort)
            updatePreferences()
        }
        .onChange(of: vm.fastMode) {
            isSpeedModeEnabled = vm.fastMode != "standard"
            updatePreferences()
        }
        .onChange(of: isSpeedModeEnabled) {
            vm.fastMode = isSpeedModeEnabled ? enabledFastMode : "standard"
        }
    }
    
    private var animationsEnabled: Bool {
        bigAssAnimations && !reduceMotion
    }
    
    private var modelTitle: String {
        CodexModelNameFormatter.title(for: vm.codexModel)
    }
    
    private var enabledFastMode: String {
        vm.fastModeOptions.first { $0 != "standard" } ?? "fast"
    }

    private var preferencesLocked: Bool {
        vm.preferencesLocked
    }
    
    private var openPanelCenterY: CGFloat {
        max(openPanelSize.height / 2, presentation.composerFrame.midY)
    }
    
    private var openOverlayOffset: CGFloat {
        presentation.isModelPickerPresented ? -20 : 0
    }
    
    private var openContentCenteringOffset: CGFloat {
        presentation.isModelPickerPresented ? 15 : 0
    }
    
    private func reasoningEffort(for level: ModelLevel) -> String {
        vm.codexReasoningEffortOptions.first {
            ModelLevel(reasoningEffort: $0) == level
        } ?? level.reasoningEffort
    }
    
    private func commitReasoningEffort(_ level: ModelLevel) {
        vm.codexReasoningEffort = reasoningEffort(for: level)
    }
    
    private func setOverlayOpen(_ isOpen: Bool) {
        guard animationsEnabled else {
            presentation.isModelPickerPresented = isOpen
            return
        }
        
        withAnimation(.default.speed(1.5)) {
            presentation.isModelPickerPresented = isOpen
        }
    }

    private func updatePreferences() {
        Task {
            await vm.updatePreferences()
        }
    }
}

#Preview {
    ChatComposerModelPicker(
        presentation: .constant(ChatComposerPresentationState(
            labelFrame: CGRect(x: 200, y: 600, width: 100, height: 30),
            sliderFrame: CGRect(x: 250, y: 615, width: 1, height: 1),
            speedModeFrame: CGRect(x: 304, y: 600, width: 30, height: 30)
        ))
    )
    .frame(width: 390, height: 700)
    .darkSchemePreferred()
    .environment(CodexChatVM())
}
