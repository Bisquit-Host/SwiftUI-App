import SwiftUI

struct LoginDivider: View {
    var body: some View {
        HStack {
            VStack {
                Divider()
            }
            
            Text("or")
                .secondary()
            
            VStack {
                Divider()
            }
        }
        .padding(8)
    }
}

#Preview {
    LoginDivider()
        .darkSchemePreferred()
}
