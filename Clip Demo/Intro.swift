import ScrechKit

struct Intro: View {
    @Environment(NavState.self) private var navState
    
    var body: some View {
        Button("Demo Preview") {
            navState.navigate(.toServerList)
        }
    }
}

#Preview {
    Intro()
        .environment(NavState())
}
