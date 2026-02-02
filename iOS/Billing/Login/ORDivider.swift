import SwiftUI

struct ORDivider: View {
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
    ORDivider()
        .darkSchemePreferred()
}
