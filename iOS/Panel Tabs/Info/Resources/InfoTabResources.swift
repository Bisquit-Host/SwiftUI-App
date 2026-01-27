import SwiftUI
import PteroNet

struct InfoTabResources: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        InfoAbsoluteStats(server.limits, showsUptime: true)
            .frame(height: 60)
            .padding(.horizontal)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray.opacity(0.25), lineWidth: 1)
            }
    }
}

#Preview {
    InfoTabResources(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
