import SwiftUI

struct LogTopbarCard: View {
    let title: LocalizedStringKey
    let icon: String
    let iconColor: Color
    let value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                
                Text(value)
                    .semibold()
            }
            
            Text(title)
                .secondary()
        }
    }
}
