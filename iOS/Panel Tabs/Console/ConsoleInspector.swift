import SwiftUI

struct ConsoleInspector: View {
    @Environment(ConsoleVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                Stepper("Font Size: \(Int(vm.fontSize))", value: $vm.fontSize)
            }
            
            Section {
                Toggle("Messenger style", isOn: $store.consoleMessengerDesign)
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
        .environmentObject(ValueStore())
}
