import SwiftUI

struct ServerCardSuspended: View {
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 32) {
                VStack {
                    Text(name)
                    
                    Text("Is Suspended")
                        .bold()
                }
                .title3()
                
                Image(systemName: "snowflake")
                    .largeTitle()
            }
            
            Capsule()
                .frame(width: 500, height: 5)
                .padding(.bottom)
            
            Text("Contact support")
        }
    }
}

#Preview {
    ServerCardSuspended("Test Server")
        .darkSchemePreferred()
}
