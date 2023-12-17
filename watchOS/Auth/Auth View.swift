import SwiftUI

struct AuthView: View {
    @Bindable private var typing = TypeTextVM()
    @Environment(NavState.self) private var navState
    
    var body: some View {
        VStack {
            Text(typing.finalTitle)
                .hidden()
                .lineLimit(1)
                .monospaced()
                .padding(.horizontal, 50)
                .overlay(alignment: .leading) {
                    Text(typing.titleText)
                        .monospaced()
                        .padding(.leading, 30)
                }
        }
        .task {
            try? await Task.sleep(for: .seconds(4))
            
            navState.navigate(.toServerList)
        }
        .typeText(
            $typing.titleText,
            isFinished: $typing.isTitleFinished,
            finalText: typing.finalTitle,
            isAnimated: !typing.isTitleFinished
        )
        .animation(
            .default.speed(0.25),
            value: typing.isTitleFinished
        )
    }
}

#Preview {
    AuthView()
        .environment(NavState())
}
