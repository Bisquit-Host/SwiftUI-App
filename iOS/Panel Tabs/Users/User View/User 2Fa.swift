import SwiftUI

struct User2Fa: View {
    private let isEnabled: Bool
    
    init(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        HStack {
            Text("2FA")
            
            Spacer()
            
            if isEnabled {
                Group {
                    Text("Enabled")
                    
                    Image(systemName: "lock.fill")
                }
                .foregroundStyle(.green)
            } else {
                Text("Disabled")
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    List {
        User2Fa(true)
        User2Fa(false)
    }
}
