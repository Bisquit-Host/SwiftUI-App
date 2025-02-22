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
                Text(name)
                    .bold()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .scaledToFit()
                
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
                Text(name)
                    .bold()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .scaledToFit()
                
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
}

#Preview {
    SuspendedServerCard("Test Server")
        .environmentObject(ValueStore())
}
