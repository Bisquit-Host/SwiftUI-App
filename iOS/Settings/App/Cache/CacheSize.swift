import ScrechKit
import Kingfisher

struct CacheSize: View {
    @Environment(CacheVM.self) private var cache
    
    var body: some View {
        Menu {
#if DEBUG
            NavigationLink("View cache") {
                CacheList()
            }
#endif
            Divider()
            
            Button("Clear entire cache", role: .destructive, action: cache.clearAll)
        } label: {
            HStack(spacing: 12) {
                GlassyIcon("chart.pie", tint: .orange)
                
                Text("Total size")
                    .subheadline(.semibold)
                
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
    .darkSchemePreferred()
    .environment(CacheVM())
}
