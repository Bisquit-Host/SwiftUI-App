//import ScrechKit
//import SwiftData
//import PteroNet
//import TipKit
//
//struct CloudKeys: View {
//    @EnvironmentObject private var settings: ValueStorage
//    @Environment(\.dismiss) private var dismiss
//    
//    @Environment(\.modelContext) private var modelContext
//    @Query(animation: .default) private var keys: [APIKey]
//    
//    @Binding private var apiKey: String
//    private let validate: () -> Void
//    
//    init(_ apiKey: Binding<String>, validate: @escaping () -> Void = {}) {
//        _apiKey = apiKey
//        self.validate = validate
//    }
//    
//    var body: some View {
//        List {
//            if !keys.isEmpty {
//                Section("API-keys") {
//                    TipView(Tip_CloudKeys())
//                    
//                    ForEach(keys) { key in
//                        Button {
//                            Keychain.save(key: "selectedApiKey", value: key.key)
//                            apiKey = key.key
//                            dismiss()
//                            validate()
//                            settings.authSucced()
//                        } label: {
//                            HStack {
//                                Text(showFirstEightLetters(key.key))
//                                
//                                Spacer()
//                                
//                                Image(systemName: "doc.on.clipboard")
//                                    .foregroundStyle(.blue)
//                            }
//                            .foregroundStyle(.foreground)
//                        }
//                    }
//                    .onDelete(perform: deleteItems)
//                }
//            }
//        }
//        .navigationTitle("iCloud")
//        .toolbarTitleDisplayMode(.inline)
//    }
//    
//    private func deleteItems(offsets: IndexSet) {
//        for index in offsets {
//            modelContext.delete(keys[index])
//        }
//    }
//    
//    private func showFirstEightLetters(_ string: String) -> String {
//        if string.count <= 8 {
//            return string
//        } else {
//            let index = string.index(string.startIndex, offsetBy: 8)
//            let truncatedString = string[string.startIndex..<index]
//            let dottedString = truncatedString + "..."
//            
//            return String(dottedString)
//        }
//    }
//}
//
//#Preview {
//    CloudKeys(.constant(""))
//        .environmentObject(ValueStorage())
//}
