import SwiftUI

struct TextFileEditor: View {
    @Environment(TextFileVM.self) private var vm
    
    var body: some View {
#if os(watchOS)
        ScrollView {
            Text(vm.text)
        }
#else
        @Bindable var vm = vm
        
        HighlightrTextView(text: $vm.text)
            .maxFrame(.infinity)
#endif
    }
}

#Preview {
    TextFileEditor()
        .darkSchemePreferred()
        .environment(TextFileVM(""))
}
