import ScrechKit

struct SuspendedServerCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    private var rounding: CGFloat {
        switch store.designCode {
        case 0: 25
        default: 16
        }
    }
    
    var body: some View {
        HStack {
            Text(name)
                .bold()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .scaledToFit()
            
            Image(systemName: "snowflake")
                .largeTitle()
                .symbolEffect(.pulse, options: .repeating)
        }
        .frame(maxWidth: 600, maxHeight: 200)
        .padding(10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: rounding))
    }
}

#Preview {
    SuspendedServerCard("Test Server")
        .environmentObject(ValueStore())
}
