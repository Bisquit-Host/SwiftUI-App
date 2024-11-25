import ScrechKit

struct InspectorButton: View {
    @Binding private var inspectorPresented: Bool
    
    init(_ inspectorPresented: Binding<Bool>) {
        _inspectorPresented = inspectorPresented
    }
    
    var body: some View {
        SFButton("bold.italic.underline") {
            inspectorPresented = true
        }
        .semibold()
        .foregroundColor(.primary)
    }
}

#Preview {
    @Previewable @State var inspectorPresented = true
    
    InspectorButton($inspectorPresented)
}
