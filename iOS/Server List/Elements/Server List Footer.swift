import SwiftUI

struct ServerListFooter: View {
    @Environment(ServerListVM.self) private var vm
    
    var body: some View {
        VStack {
            Text("Designed by Bisquit.Host in Amsterdam")
            Text("Compiled in Russia with love ♥️")
        }
        .footnote()
        .foregroundStyle(.gray)
        .padding()
        .redacted(vm.footerHidden)
        .animation(.default, value: vm.footerHidden)
        .onTapGesture {
            vm.switchFooter()
        }
    }
}
