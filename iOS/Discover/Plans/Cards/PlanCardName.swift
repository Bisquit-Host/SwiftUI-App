import SwiftUI

struct PlanCardName: View {
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        Text(name)
            .title(.semibold)
            .foregroundStyle(.white)
            .shadow(color: .black, radius: 5)
    }
}

#Preview {
    PlanCardName("Preview")
        .darkSchemePreferred()
}
