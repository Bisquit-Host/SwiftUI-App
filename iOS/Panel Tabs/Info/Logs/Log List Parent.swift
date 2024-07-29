import ScrechKit

struct LogListParent: View {
    var body: some View {
        
#if os(watchOS)
        LogList()
#else
        NavigationView {
            LogList()
        }
#endif
    }
}

#Preview {
    Text("Preview")
        .sheet {
            LogListParent()
        }
        .environment(LogVM(""))
}
