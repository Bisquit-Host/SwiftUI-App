import SwiftUI

struct ConsoleMessage: View {
    @Environment(ConsoleVM.self) private var vm
    @Environment(PanelVM.self) private var panelVM
    
    private let message: AttributedString
    private let index: Range<Array<AttributedString>.Index>.Element
    
    init(
        _ message: AttributedString,
        index: Range<Array<AttributedString>.Index>.Element
    ) {
        self.message = message
        self.index = index
    }
    
    @State private var fontDesign: Font.Design = .monospaced
    
    var body: some View {
        Text(message)
            .fontDesign(fontDesign)
            .fontSize(vm.fontSize)
            .multilineTextAlignment(.leading)
            .onAppear {
                if index == panelVM.searchedMessages.count - 1 {
                    vm.lastMessageIndex = index
                }
            }
    }
}

#Preview {
    ConsoleMessage("Preview", index: 0)
        .environment(ConsoleVM(""))
        .environment(PanelVM(""))
}
