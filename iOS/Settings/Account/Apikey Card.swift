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
                        .foregroundStyle(.secondary)
                }
                
                Text("Created: \(timeSinceISO(key.created))")
                    .footnote()
                
                if let last_used = key.last_used {
                    Text("Last used: \(timeSinceISO(last_used))")
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
