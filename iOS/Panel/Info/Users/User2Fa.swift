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
                let icon = Image(systemName: "lock.fill")
                
                Text("Enabled \(icon)")
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
