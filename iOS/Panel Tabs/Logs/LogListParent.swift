import ScrechKit

struct LogListParent: View {
    var body: some View {
#if os(watchOS)
        LogList()
#else
        NavigationStack {
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
        .darkSchemePreferred()
        .environment(LogVM(""))
}
