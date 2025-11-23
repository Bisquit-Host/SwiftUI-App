import ScrechKit

struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button { // Do not use SFButton()
            dismiss()
        } label: {
            Image(systemName: "xmark")
        }
        .foregroundStyle(.red)
    }
}
