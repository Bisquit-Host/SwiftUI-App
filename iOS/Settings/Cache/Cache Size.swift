import ScrechKit
import Kingfisher

struct CacheSize: View {
    @Environment(CacheVM.self) private var cache
    
    var body: some View {
        Menu {
            Button("Clear entire cache", role: .destructive) {
                cache.clearAll()
            }
        } label: {
            HStack {
                Text("Total size")
                
                Spacer()
                
                Text(cache.cacheSize)
                
                Image(systemName: "chevron.forward")
                    .caption2(.bold)
                    .foregroundStyle(.tertiary)
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
