import ScrechKit

struct SuspendedServerCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        HStack {
            serverName
            
            Image(systemName: "snowflake")
                .largeTitle()
                .symbolEffect(.pulse, options: .repeating)
        }
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }
    
    private var serverName: some View {
        Text(name)
            .bold()
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .scaledToFit()
            .blur(radius: store.hideServerNames ? 5 : 0)
    }
}

#Preview {
    SuspendedServerCard("Test Server")
}
