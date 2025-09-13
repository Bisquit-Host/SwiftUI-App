import SwiftUI

struct Placeholder: View {
    private let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
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
