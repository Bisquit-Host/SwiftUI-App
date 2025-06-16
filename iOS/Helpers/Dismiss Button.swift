import ScrechKit

#warning("Remove?")
struct DismissButton: View {
    var dismiss: () -> Void
    
    var body: some View {
        // Do not use SFButton()
        
        Button(action: dismiss) {
            Image(systemName: "xmark")
        }
    }
}
