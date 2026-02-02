import SwiftUI

struct ServiceExpiresIn: View {
    private let expiresAt: Date?
    
    init(_ expiresAt: Date?) {
        self.expiresAt = expiresAt
    }
    
    var body: some View {
        if let expiresAt {
            LabeledContent {
                VStack(alignment: .trailing) {
                    let expireDate = expiresAt.formatted(date: .numeric, time: .shortened)
                    let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day ?? 0
                    
                    Text(expireDate)
                    
                    if daysLeft > 0 {
                        Text("in \(daysLeft) days")
                            .footnote()
                            .tertiary()
                    }
                }
            } label: {
                Text("Expires")
            }
            .subheadline()
        }
    }
}

//#Preview {
//    ServiceExpiresIn()
//}
