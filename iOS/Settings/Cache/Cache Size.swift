import ScrechKit
import Kingfisher

struct CacheSize: View {
    private var cache = CacheVM()
    
    var body: some View {
        Menu {
            Button("Clear cache", role: .destructive) {
                cache.clearAll()
            }
        } label: {
            HStack {
                Text("Cache size")
                
                Spacer()
                
                Text(cache.cacheSize)
                
                Image(systemName: "chevron.forward")
                    .foregroundStyle(.secondary)
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
