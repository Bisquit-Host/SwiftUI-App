import SwiftUI

struct ConsoleMessengerMessage: View {
    @Environment(ConsoleVM.self) private var vm
    @Environment(PanelVM.self) private var panelVM
    
    private let message: AttributedString
    private let index: Int
    
    init(_ message: AttributedString, index: Int) {
        self.message = message
        self.index = index
    }
    
    @State private var fontDesign: Font.Design = .monospaced
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Text(message)
                .fontDesign(fontDesign)
                .fontSize(vm.fontSize)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: .rect(cornerRadius: 18))
            
            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            if index == panelVM.searchedMessages.count - 1 {
                vm.lastMessageIndex = index
            }
        }
    }
}

#Preview {
    ConsoleMessengerMessage("Preview output message", index: 0)
        .darkSchemePreferred()
        .environment(ConsoleVM(""))
        .environment(PanelVM(""))
}
