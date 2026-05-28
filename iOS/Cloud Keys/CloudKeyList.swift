import ScrechKit
import SwiftData
import PteroNet
import TipKit

struct CloudKeyList: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var store: ValueStore
    @Query(animation: .default) private var keys: [APIKey]
    
    @Binding private var apiKey: String
    private let validate: () async -> Void
    
    init(_ apiKey: Binding<String>, validate: @escaping () async -> Void = {}) {
        _apiKey = apiKey
        self.validate = validate
    }
    
    var body: some View {
        List {
            Section {
                TipView(TipCloudKeys())
                    .tipBackground(.ultraThinMaterial)
                
                ForEach(keys) {
                    CloudKeyCard($apiKey, key: $0, validate: validate)
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle("Accounts")
        .ornamentDismissButton()
        .scrollIndicators(.never)
        .overlay {
            if keys.isEmpty {
                ContentUnavailableView(
                    "No accounts found",
                    systemImage: "exclamationmark.triangle",
                    description: nil
                )
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let key = keys[index]
            
            if Keychain.load(key: "selectedApiKey") == key.key {
                Keychain.delete(key: "selectedApiKey")
                store.isApiKeyValid = false
            }
            
            modelContext.delete(key)
        }
    }
}

#Preview {
    @Previewable @State var apiKey = ""
    
    Text("Preview")
        .sheet {
            CloudKeyList($apiKey)
        }
        .darkSchemePreferred()
}
