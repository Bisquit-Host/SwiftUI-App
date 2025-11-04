import ScrechKit

struct SuspendedServerCard: View {
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(name)
                    Text("is Suspended")
                }
                
                Spacer()
                
                Image(systemName: "externaldrive.badge.exclamationmark")
                    .title2()
                    .symbolRenderingMode(.multicolor)
                    .symbolEffect(.pulse)
            }
            .padding(.horizontal)
            
            Divider()
            
            Text("Contact Support!")
        }
    }
}

#Preview {
    SuspendedServerCard("Preview")
        .darkSchemePreferred()
}
