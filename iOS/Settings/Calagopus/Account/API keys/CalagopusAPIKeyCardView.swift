import ScrechKit
import Calagopus

struct CalagopusAPIKeyCardView: View {
    @Environment(CalagopusAPIKeyVM.self) private var vm
    
    private let key: CalagopusAPIKey
    
    init(_ key: CalagopusAPIKey) {
        self.key = key
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(key.name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                Spacer()
                
                Text(key.id + "...")
                    .footnote()
                    .secondary()
            }
            
            Text(timeSinceISO(key.createdAt))
                .secondary()
                .footnote()
            
            if let lastUsed = key.lastUsedAt {
                let lastUsed = Text(timeSinceISO(lastUsed))
                    .foregroundStyle(.primary)
                
                Text("Last used: \(lastUsed)")
                    .footnote()
                    .secondary()
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
        CalagopusAPIKeyCardView(CalagopusAPIKey(id: "ptla_abcdef", name: "Demo key", lastUsedAt: nil, createdAt: "2026-01-01T12:00:00Z"))
    }
    .darkSchemePreferred()
    .environment(CalagopusAPIKeyVM())
}
