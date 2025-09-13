import SwiftUI

struct StatusPill: View {
    var status: Project.Status
    
    var body: some View {
        Text(status.title)
            .caption(.semibold)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(status.bg, in: .capsule)
    }
}
