import ScrechKit
import Kingfisher

struct CacheSize: View {
    @Environment(CacheVM.self) private var cache
    
    var body: some View {
        Menu {
            Section {
                Button("Clear entire cache", role: .destructive) {
                    cache.clearAll()
                }
            }
        } label: {
            HStack {
                Text("Total size")
                
                Spacer()
                
                Text(cache.cacheSize)
                    .secondary()
                
                Image(systemName: "chevron.forward")
                    .caption2(.bold)
                    .tertiary()
            }
            .foregroundStyle(.foreground)
        }
        .task {
            cache.calculateCacheSize()
        }
    }
}

#Preview {
    List {
        CacheSize()
    }
}
