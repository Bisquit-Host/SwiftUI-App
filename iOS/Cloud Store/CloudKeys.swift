import ScrechKit
import SwiftData
import PteroNet
import TipKit

struct CloudKeys: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    @Binding private var apiKey: String
    private let validate: () -> Void
    
    init(
        _ apiKey: Binding<String>,
        validate: @escaping () -> Void = {}
    ) {
        _apiKey = apiKey
        self.validate = validate
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TipView(TipCloudKeys())
                        .tipBackground(.ultraThinMaterial)
                    
                    ForEach(keys) {
                        CloudKeyCard($apiKey, key: $0) {
                            dismiss()
                            validate()
                        }
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
        .darkSchemePreferred()
}
