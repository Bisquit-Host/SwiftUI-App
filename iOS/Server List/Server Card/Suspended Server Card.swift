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
        switch store.designCode {
        case 0:
            VStack(spacing: 10) {
                serverName
                
                Image(systemName: "snowflake")
                    .fontSize(50)
                    .symbolEffect(.pulse, options: .repeating)
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: rounding))
            
        default:
            HStack {
                serverName
                
                Image(systemName: "snowflake")
                    .largeTitle()
                    .symbolEffect(.pulse, options: .repeating)
            }
            .frame(height: 90)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: rounding))
        }
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
        .environmentObject(ValueStore())
}
