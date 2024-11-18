import ScrechKit
import PteroNet

struct ApikeyCard: View {
    private let key: ApiKeyAttributes
    
    init(_ key: ApiKeyAttributes) {
        self.key = key
    }
    
    var body: some View {
        HStack {
            Image(systemName: "key.radiowaves.forward.fill")
                .title()
                .padding(.trailing, 8)
                .symbolEffect(.variableColor)
                .foregroundStyle(.yellow)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(key.description)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Spacer()
                    
                    Text(key.id + "...")
                        .footnote()
                        .secondary()
                }
                
                Text("Created: \(timeSinceISO(key.created))")
                    .footnote()
                
                if let lastUsed = key.lastUsed {
                    Text("Last used: \(timeSinceISO(lastUsed))")
                        .footnote()
                }
            }
        }
    }
}

#Preview {
    List {
        ApikeyCard(
            sampleJSON(.apiKeyListAttributes)
        )
    }
}
