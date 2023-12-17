import ScrechKit

struct LogListParent: View {
    var body: some View {
        
#if !os(watchOS)
        NavigationView {
            LogList()
        }
#else
        LogList()
#endif
    }
}

#Preview {
    Text("Preview")
        .sheet(.constant(true)) {
            LogListParent()
        }
        .environment(LogVM(""))
}
