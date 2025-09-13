import SwiftUI

struct Placeholder: View {
    var title: String
    
    var body: some View {
        ZStack {
            Color(.windowBackgroundColor)
            
            VStack(spacing: 10) {
                Image(systemName: "square.grid.3x1.folder.fill.badge.plus")
                    .fontSize(48)
                
                Text(title)
                    .title(.semibold)
            }
        }
        .ignoresSafeArea()
    }
}
