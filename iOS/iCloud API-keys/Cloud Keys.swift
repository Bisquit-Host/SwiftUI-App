import ScrechKit
import SwiftData
import PteroNet
import TipKit

struct CloudKeys: View {
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    @Binding private var apiKey: String
    private let validate: () -> Void
    
    init(_ apiKey: Binding<String>, validate: @escaping () -> Void = {}) {
        _apiKey = apiKey
        self.validate = validate
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TipView(Tip_CloudKeys())
                    
                    ForEach(keys) { key in
                        CloudKeyCard($apiKey, key: key) {
                            dismiss()
                            validate()
                        }
                    }
                    .onDelete(perform: deleteItems)
                } header: {
                    if !keys.isEmpty {
                        Text("API-keys")
                    }
                }
#if !os(watchOS)
                .listRowBackground(store.transparentList ? .clear : Color.list)
#endif
            }
#if !os(tvOS)
            .scrollContentBackground(store.transparentSheet ? .hidden : .visible)
#endif
            .ornamentDismissButton()
            .presentationBackground(store.transparentSheet ? .ultraThinMaterial : .regular)
            .navigationTitle("iCloud")
            .toolbarTitleDisplayMode(.inline)
            .overlay {
                if keys.isEmpty {
                    ContentUnavailableView(
                        "No API-keys found",
                        systemImage: "exclamationmark.triangle",
                        description: nil
                    )
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(keys[index])
        }
    }
}

#Preview {
    @Previewable @State var apiKey = ""
    
    Text("Preview")
        .sheet {
            CloudKeys($apiKey)
        }
}
