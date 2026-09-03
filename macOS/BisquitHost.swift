import ScrechKit

@main
struct BisquitHost: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                Text("The Bisquit.Host app for macOS is moving beyond the App Store")
                    .title()
                
                Text("Download the new version and learn more at [bisquit.host](https://bisquit.host)")
                    .secondary()
            }
            .multilineTextAlignment(.center)
            .padding()
        }
    }
}
