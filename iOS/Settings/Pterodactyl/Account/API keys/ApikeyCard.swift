import ScrechKit
import Calagopus

struct ApikeyCard: View {
    @Environment(ApikeyVM.self) private var vm
    
    private let key: ApiKeyAttributes
    
    init(_ key: ApiKeyListData) {
        self.key = key.attributes
    }
    
    var body: some View {
        HStack {
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
                
                Text(timeSinceISO(key.created))
                    .secondary()
                    .footnote()
                
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
            Button("Delete", systemImage: "trash", role: .destructive, action: delete)
        }
    }
    
    private func delete() {
        Task {
            await vm.delete(key.id)
        }
    }
}

#Preview {
    List {
        ApikeyCard(PreviewProp.apiKeyListData)
    }
    .darkSchemePreferred()
    .environment(ApikeyVM())
}
