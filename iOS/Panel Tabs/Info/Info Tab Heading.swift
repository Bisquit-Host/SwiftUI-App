import SwiftUI
import PteroNet

struct InfoTabHeading: View {
    @Environment(PanelVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(server.name)
                .largeTitle(.bold)
                .lineLimit(1)
            
            Group {
                if server.description.isEmpty {
                    Button("Add a description") {
                        vm.sheetSettings = true
                    }
                } else {
                    Text(server.description)
                }
            }
            .title3(.semibold)
            .secondary()
            .lineLimit(1)
            
            Text(server.id)
                .footnote()
                .foregroundStyle(.tertiary)
                .shadow(color: .black, radius: 5)
                .onTapGesture {
                    UIPasteboard.general.string = server.id
                    SystemAlert.copied()
                }
        }
        .rounded()
    }
}
