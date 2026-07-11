import ScrechKit

struct ModelLabelView: View {
    @AppStorage("big_ass_animations") private var bigAssAnimations = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let modelTitle: String
    let reasoningTitle: String
    var reservesReasoningWidth = false
    var isSpeedModeEnabled: Bool? = nil
    var speedModeCoordinateSpaceName: String? = nil
    var speedModeFrameChanged: ((CGRect) -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            Text(modelTitle)
                .callout(.semibold)

            if reservesReasoningWidth {
                ZStack(alignment: .leading) {
                    ForEach(ModelLevel.allCases, id: \.self) { level in
                        HStack(spacing: 1) {
                            Text(level.title)
                                .callout()

                            Image(systemName: "chevron.forward")
                                .caption(.semibold)
                        }
                        .hidden()
                    }

                    HStack(spacing: 1) {
                        Text(reasoningTitle)
                            .callout()

                        Image(systemName: "chevron.forward")
                            .caption(.semibold)
                    }
                    .secondary()
                    .contentTransition(.numericText())
                    .animation(
                        bigAssAnimations && !reduceMotion ? .smooth(duration: 0.25) : nil,
                        value: reasoningTitle
                    )
                }
            } else {
                Text(reasoningTitle)
                    .callout()
                    .secondary()
            }

            if let isSpeedModeEnabled {
                SpeedModeIconView(
                    isEnabled: isSpeedModeEnabled,
                    textStyle: .callout,
                    coordinateSpaceName: speedModeCoordinateSpaceName,
                    frameChanged: speedModeFrameChanged
                )
            }
        }
        .rounded()
    }
}
