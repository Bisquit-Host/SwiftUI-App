import ScrechKit
import PteroNet

struct ApikeyCard: View {
    @Environment(ApikeyVM.self) private var vm
    
    private let key: ApiKeyAttributes
    
    init(_ key: ApiKeyListData) {
        self.key = key.attributes
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
                
                let created = Text(timeSinceISO(key.created))
                    .foregroundStyle(.primary)
                
                Text("Created: \(created)")
                    .footnote()
                    .secondary()
                
                if let lastUsed = key.lastUsed {
                    let lastUsed = Text(timeSinceISO(lastUsed))
                        .foregroundStyle(.primary)
                    
                    Text("Last used: \(lastUsed)")
                        .footnote()
                        .secondary()
                }
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                vm.delete(key.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    List {
        ApikeyCard(sampleJSON(.apiKeyListAttributes))
    }
    .environment(ApikeyVM())
}
