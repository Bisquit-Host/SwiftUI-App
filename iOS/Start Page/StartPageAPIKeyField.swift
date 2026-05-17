import ScrechKit

struct StartPageAPIKeyField: View {
    @Environment(StartPageVM.self) private var vm
    @EnvironmentObject var store: ValueStore
    
    @FocusState.Binding private var isFocused: Bool
    
    init(_ isFocused: FocusState<Bool>.Binding) {
        _isFocused = isFocused
    }
    
    @State private var trigger = false
    
    var body: some View {
        @Bindable var vm = vm
        
        let base = TextField("API key", text: $vm.apiKey)
            .secondary()
            .autocorrectionDisabled()
            .frame(height: 40)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)
            .glassEffect()
            .focused($isFocused)
        
        if store.bigAssAnimations {
            base.changeEffect(.shake(rate: .fast), value: trigger)
        } else {
            base
        }
    }
}

#Preview {
    @Previewable @FocusState var isFocused
    
    StartPageAPIKeyField(isFocused: $isFocused)
        .padding()
        .darkSchemePreferred()
}
