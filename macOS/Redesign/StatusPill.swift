import SwiftUI

struct StatusPill: View {
    private let status: Project.Status
    
    init(_ status: Project.Status) {
        self.status = status
    }
    
    var body: some View {
        Text(status.title)
            .caption(.semibold)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(status.bg, in: .capsule)
    }
}
