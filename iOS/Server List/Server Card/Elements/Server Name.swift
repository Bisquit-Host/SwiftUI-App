import SwiftUI

struct ServerName: View {
    @EnvironmentObject private var store: ValueStore
    
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        Text(name)
            .headline()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .blur(radius: store.hideServerNames ? 5 : 0)
    }
}

#Preview {
    ServerName("Preview")
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
