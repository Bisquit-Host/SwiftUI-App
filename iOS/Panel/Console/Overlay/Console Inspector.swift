import SwiftUI

struct ConsoleInspector: View {
    @Environment(ConsoleVM.self) private var vm
    
    var body: some View {
        @Bindable var binding = vm
        
        List {
            Stepper("Font Size: \(Int(vm.fontSize))", value: $binding.fontSize)
            
            Slider(value: $binding.fontSize, in: 6...16)
            
//            Toggle("coloredTextEnabled", isOn: $settings.coloredTextEnabled)
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ConsoleInspector()
        .environment(ConsoleVM(""))
}
