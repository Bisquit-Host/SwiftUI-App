import ScrechKit

struct AuthView: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        VStack {
            //            Text(typing.finalTitle)
            //                .hidden()
            //                .monospaced()
            //                .fontSize(64)
            //                .padding(.horizontal, 70)
            //                .overlay(alignment: .leading) {
            //                    Text(typing.titleText)
            //                        .monospaced()
            //                        .padding(.leading, 70)
            //                        .fontSize(64)
            //                }
            
            //            AsyncImage(url: getImageUrl("bisquit")) { image in
            //                image
            //                    .resizable()
            //                    .frame(depth: 32)
            //                    .frame(300)
            //            } placeholder: {
            //                ProgressView()
            //            }
            //            .opacity(typing.isTitleFinished ? 1 : 0)
        }
        .task {
            await vm.fetchServers(store.adminServerList)
            
            delay(2) {
                navState.navigate(.toServerList)
            }
        }
    }
}

#Preview {
    AuthView()
        .darkSchemePreferred()
        .padding()
        .glassBackgroundEffect()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
