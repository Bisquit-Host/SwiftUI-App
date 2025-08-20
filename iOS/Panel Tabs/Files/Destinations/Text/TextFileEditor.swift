import SwiftUI

struct TextFileEditor: View {
    @Environment(TextFileVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
#if os(watchOS)
        ScrollView {
            Text(vm.text)
        }
#else
        HighlightrTextView(text: $vm.text)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
    }
}

#Preview {
    TextFileEditor()
        .darkSchemePreferred()
        .environment(TextFileVM(""))
}
