import SwiftUI

struct LogMetaCard: View {
    private let key, value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    var body: some View {
#if os(tvOS)
        Button {
            
        } label: {
            HStack {
                Text(key)
                
                Spacer()
                
                Text(value)
                    .secondary()
            }
        }
#else
        Section(key) {
            Text(value)
        }
#endif
    }
}

//#Preview {
//    LogMetaCard()
//    .darkSchemePreferred()
//}
