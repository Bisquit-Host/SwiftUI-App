import ScrechKit

struct SuspendedServerCard: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    private var corner: CGFloat {
        switch settings.designCode {
        case 0: 22
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
        .background(.ultraThinMaterial, in: .rect(cornerRadius: corner))
    }
}

#Preview {
    SuspendedServerCard("Test Server")
        .environmentObject(SettingsStorage())
}
