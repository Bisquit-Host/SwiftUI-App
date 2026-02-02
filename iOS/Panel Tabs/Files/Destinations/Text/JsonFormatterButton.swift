import ScrechKit

struct JsonFormatterButton: View {
    @Environment(TextFileVM.self) private var vm
    
    private var tip = TipJsonFormatter()
    
    var body: some View {
        if vm.showPrettyButton {
            Button("ellipsis.curlybraces", action: prettify)
                .popTip(tip) {
                    if $0.id == "format-json" {
                        Task { @MainActor in
                            vm.makePretty()
                        }
                    }
                }
        }
    }
    
    private func prettify() {
        tip.invalidate(reason: .actionPerformed)
        vm.makePretty()
    }
}

#Preview {
    JsonFormatterButton()
        .darkSchemePreferred()
        .environment(TextFileVM(""))
}
