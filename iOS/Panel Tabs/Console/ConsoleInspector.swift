import SwiftUI

struct ConsoleInspector: View {
    @Environment(ConsoleVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                Stepper("Font Size: \(Int(vm.fontSize))", value: $vm.fontSize)
                
                Slider(value: $vm.fontSize, in: 6...16)
            }
            
            // Toggle("coloredTextEnabled", isOn: $store.coloredTextEnabled)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    ConsoleInspector()
        .darkSchemePreferred()
        .environment(ConsoleVM(""))
}
