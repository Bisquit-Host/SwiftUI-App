import ScrechKit

struct DismissButton: View {
    var dismiss: () -> Void
    
    var body: some View {
        // Do not use SFButton()
        
        Button(action: dismiss) {
            Image(systemName: "xmark")
        }
        .foregroundStyle(.red)
    }
}
