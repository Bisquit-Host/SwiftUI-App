import SwiftUI
import PteroNet

struct InfoTab: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(server.name)
                    .largeTitle()
                
                Spacer()
                
                Button(server.id) {
                    print("1")
                }
                .padding(8)
            }
            
            Text(server.description)
                .title3(.semibold)
                .lineLimit(1)
        }
        .padding()
        .glassBackgroundEffect()
        .frame(width: 600)
    }
}

#Preview {
    InfoTab(PreviewProperty.serverAttributes)
        .padding()
        .glassBackgroundEffect()
}
