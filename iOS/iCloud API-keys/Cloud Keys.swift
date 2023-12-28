import ScrechKit
import SwiftData
import PteroNet
import TipKit

struct CloudKeys: View {
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var apiKey: String
    private let validate: () -> Void
    
    init(_ apiKey: Binding<String>,
         validate: @escaping () -> Void = {}
    ) {
        _apiKey = apiKey
        self.validate = validate
    }
    
    var body: some View {
        NavigationView {
            List {
                if keys.isEmpty {
                    ContentUnavailableView("No API-keys found",
                                           systemImage: "exclamationmark.triangle",
                                           description: nil)
                } else {
                    Section("API-keys") {
                        TipView(Tip_CloudKeys())
                        
                        ForEach(keys) { key in
                            CloudKeyCard($apiKey, key: key) {
                                dismiss()
                                validate()
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
#if os(xrOS)
                Button {
                    dismiss()
                } label: {
                    Text("Dismiss")
                }
#endif
            }
            .navigationTitle("iCloud")
            .toolbarTitleDisplayMode(.inline)
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
    CloudKeys(.constant(""))
}
