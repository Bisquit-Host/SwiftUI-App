import SwiftUI

struct LogMetaCard: View {
    private let key, value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    var body: some View {
        Section(key) {
            Text(value)
        }
    }
}

//#Preview {
//    LogMetaCard()
//        .darkSchemePreferred()
//}
