import ScrechKit

struct JsonFormatterButton: View {
    @Environment(TextFileVM.self) private var vm
    
    private var tip = Tip_JsonFormatter()
    
    var body: some View {
        if vm.showPrettyButton {
            Button("ellipsis.curlybraces") {
                tip.invalidate(reason: .actionPerformed)
                vm.makePretty()
            }
            .popTip(tip) { action in
                if action.id == "format-json" {
                    vm.makePretty()
                }
            }
        }
    }
}

#Preview {
    JsonFormatterButton()
        .environment(TextFileVM(""))
}
