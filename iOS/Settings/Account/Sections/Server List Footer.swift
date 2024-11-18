import SwiftUI

struct ServerListFooter: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Designed by Bisquit.Host in Amsterdam")
            
            Text("Compiled in Russia with love ♥️")
        }
        .footnote()
        .secondary()
        .padding(.vertical, 5)
    }
}
