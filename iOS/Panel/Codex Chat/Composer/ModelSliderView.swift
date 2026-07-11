import ScrechKit

struct ModelSliderView: View {
    @Binding var selection: ModelLevel
    @State private var trackSize = CGSize.zero
    let animationsEnabled: Bool

    private let levels = ModelLevel.allCases

    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                ForEach(levels, id: \.self) { level in
                    Button {
                        selection = level
                    } label: {
                        Image(systemName: "circle.fill")
                            .caption()
                            .hidden()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(level.title)
                }
            }

            ForEach(levels, id: \.self) { level in
                Image(systemName: "circle.fill")
                    .caption()
                    .foregroundStyle(.white.opacity(0.35))
                    .position(
                        x: dotPosition(for: level),
                        y: trackSize.height / 2
                    )
                    .allowsHitTesting(false)
            }

            Capsule()
                .fill(selection == .xhigh ? .indigo : .white)
                .frame(width: fillWidth(), height: trackSize.height)
                .allowsHitTesting(false)
        }
        .onGeometryChange(for: CGSize.self) {
            $0.size
        } action: {
            trackSize = $0
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged {
                    updateSelection(at: $0.location.x)
                }
        )
        .padding(6)
        .background(.gray, in: .capsule)
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
            switch $0 {
            case .increment:
                selection = ModelLevel(rawValue: min(selection.rawValue + 1, levels.count - 1)) ?? selection
            case .decrement:
                selection = ModelLevel(rawValue: max(selection.rawValue - 1, 0)) ?? selection
            @unknown default:
                break
            }
        }
    }

    private func updateSelection(at location: CGFloat) {
        guard trackSize.width > 0 else { return }

        let stepWidth = trackSize.width / CGFloat(levels.count)
        let rawValue = min(max(Int(location / stepWidth), 0), levels.count - 1)
        selection = ModelLevel(rawValue: rawValue) ?? selection
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
