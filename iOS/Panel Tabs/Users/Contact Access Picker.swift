import ScrechKit

fileprivate struct ContactAccessPickerModifier: ViewModifier {
    @Binding private var isPresented: Bool
    
    init(_ isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content
                .contactAccessPicker(isPresented: $isPresented)
                .toolbar {
                    SFButton("person.crop.circle.badge.plus") {
                        isPresented = true
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    func contactAccessPicker(_ isPresented: Binding<Bool>) -> some View {
        self.modifier(ContactAccessPickerModifier(isPresented))
    }
}
