import ScrechKit

struct ModelSliderView: View {
    @Binding var selection: ModelLevel
    @Environment(\.isEnabled) private var isEnabled
    @State private var trackSize = CGSize.zero
    let isFastModeEnabled: Bool
    let particleFlowEnabled: Bool
    let animationsEnabled: Bool
    let selectionCommitted: (ModelLevel) -> Void

    private let levels = ModelLevel.allCases

    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                ForEach(levels, id: \.self) { _ in
                    Image(systemName: "circle.fill")
                        .caption()
                        .hidden()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                }
            }
            .allowsHitTesting(false)

            Capsule()
                .fill(selection == .xhigh ? .indigo : .white)
                .frame(width: fillWidth(), height: trackSize.height)
                .allowsHitTesting(false)

            if animationsEnabled,
               particleFlowEnabled,
               isFastModeEnabled {
                ModelSliderParticleFlowView()
                    .frame(width: trackSize.width, height: trackSize.height)
                    .frame(width: fillWidth(), alignment: .leading)
                    .clipShape(.capsule)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }

            ForEach(levels, id: \.self) { level in
                if !isFastModeEnabled || level.rawValue > selection.rawValue {
                    Image(systemName: "circle.fill")
                        .caption()
                        .foregroundStyle(
                            level.rawValue <= selection.rawValue
                            ? .black.opacity(0.35)
                            : .white.opacity(0.35)
                        )
                        .position(
                            x: dotPosition(for: level),
                            y: trackSize.height / 2
                        )
                        .allowsHitTesting(false)
                }
            }
        }
        .onGeometryChange(for: CGSize.self) {
            $0.size
        } action: {
            trackSize = $0
        }
        .contentShape(.rect)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged {
                    updateSelection(at: $0.location.x)
                }
                .onEnded {
                    commitSelection(at: $0.location.x)
                }
        )
        .padding(6)
        .background(.black, in: .capsule)
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.16))
        }
        .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
        .animation(animationsEnabled ? .smooth(duration: 0.25) : nil, value: selection)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Model level")
        .accessibilityValue(selection.title)
        .accessibilityAdjustableAction {
            let updatedSelection: ModelLevel

            switch $0 {
            case .increment:
                updatedSelection = ModelLevel(rawValue: min(selection.rawValue + 1, levels.count - 1)) ?? selection
            case .decrement:
                updatedSelection = ModelLevel(rawValue: max(selection.rawValue - 1, 0)) ?? selection
            @unknown default:
                return
            }

            selection = updatedSelection
            selectionCommitted(updatedSelection)
        }
    }

    private func updateSelection(at location: CGFloat) {
        guard isEnabled else { return }
        guard let updatedSelection = level(at: location) else { return }

        selection = updatedSelection
    }

    private func commitSelection(at location: CGFloat) {
        guard isEnabled else { return }
        guard let updatedSelection = level(at: location) else { return }

        selection = updatedSelection
        selectionCommitted(updatedSelection)
    }

    private func level(at location: CGFloat) -> ModelLevel? {
        guard trackSize.width > 0 else { return nil }

        let stepWidth = trackSize.width / CGFloat(levels.count)
        let rawValue = min(max(Int(location / stepWidth), 0), levels.count - 1)
        return ModelLevel(rawValue: rawValue)
    }

    private func fillWidth() -> CGFloat {
        guard levels.count > 1 else { return trackSize.height }

        let availableWidth = max(trackSize.width - trackSize.height, 0)
        let progress = CGFloat(selection.rawValue) / CGFloat(levels.count - 1)
        return trackSize.height + availableWidth * progress
    }

    private func dotPosition(for level: ModelLevel) -> CGFloat {
        guard levels.count > 1 else { return trackSize.width / 2 }

        let radius = trackSize.height / 2
        let availableWidth = max(trackSize.width - trackSize.height, 0)
        let progress = CGFloat(level.rawValue) / CGFloat(levels.count - 1)
        return radius + availableWidth * progress
    }
}
