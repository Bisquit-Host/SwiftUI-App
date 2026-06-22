import SwiftUI

struct PanelCodexChatButton: View {
    @Binding private var isPresented: Bool
    
    init(_ isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "siri")
                .resizable()
                .frame(40)
                .foregroundStyle(.orange.gradient)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .padding()
    }
}

#Preview {
    @Previewable @State var isPresented = false
    
    PanelCodexChatButton($isPresented)
        .darkSchemePreferred()
}
