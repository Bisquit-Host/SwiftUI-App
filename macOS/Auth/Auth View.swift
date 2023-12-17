import ScrechKit
import Kingfisher

struct AuthView: View {
    @State private var vm = AuthVM()
    @Bindable private var typing = TypeTextVM()
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        VStack {
            Text(typing.finalTitle)
                .hidden()
                .lineLimit(1)
                .monospaced()
                .fontSize(64)
                .padding(.horizontal, 50)
                .overlay(alignment: .leading) {
                    Text(typing.titleText)
                        .monospaced()
                        .padding(.leading, 50)
                        .fontSize(64)
                }
            
            KFImage(getImageUrl("bisquit"))
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 400, maxHeight: 400)
                .padding(32)
                .opacity(typing.isTitleFinished ? 1 : 0)
        }
        .task {
            try? await Task.sleep(for: .seconds(4))
            vm.appear(settings.useBiometry, navState: navState)
        }
        .typeText(
            $typing.titleText,
            isFinished: $typing.isTitleFinished,
            finalText: typing.finalTitle,
            isAnimated: !typing.isTitleFinished
        )
        .animation(.default.speed(0.25), value: typing.isTitleFinished)
    }
}

#Preview {
    AuthView()
        .environment(NavState())
        .environmentObject(SettingsStorage())
}
