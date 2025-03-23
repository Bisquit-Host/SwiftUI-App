import ScrechKit

struct DiscoverCard<Label: View>: View {
    private let url: String
    private let label: () -> Label
    
    init(_ url: String, label: @escaping () -> Label) {
        self.url = url
        self.label = label
    }
    
    @State private var showSafari = false
    
    var body: some View {
        Button {
            showSafari = true
        } label: {
            label()
        }
        .safariCover($showSafari, url: url)
    }
}
