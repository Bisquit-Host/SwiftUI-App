import ScrechKit

struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Do not use SFButton()
        
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
        }
        .foregroundStyle(.red)
    }
}
