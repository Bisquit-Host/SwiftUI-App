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
        .title3(.semibold)
        .foregroundColor(.primary)
        .frame(width: 35, height: 35)
        .padding(10)
        .background(.ultraThinMaterial, in: .circle)
    }
}

#Preview {
    InspectorButton(.constant(true))
}
