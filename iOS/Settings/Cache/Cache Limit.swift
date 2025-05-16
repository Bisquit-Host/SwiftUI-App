import ScrechKit

struct CacheLimit: View {
    @Environment(CacheVM.self) private var cache
    
    @AppStorage("cacheLimit") private var cacheLimit: CacheLimit = .GB1
    
    private let limits: [CacheLimit] = [.MB250, .GB1]
    
    var body: some View {
        Menu {
            ForEach(limits) { limit in
                Button(limit.loc) {
                    cacheLimit = limit
                    updateCacheLimit(limit)
                }
            }
        } label: {
            HStack {
                Text("Limit")
                
                Spacer()
                
                Text(cacheLimit.loc)
                
                Image(systemName: "chevron.forward")
                    .caption2(.bold)
                    .tertiary()
            }
        }
        .foregroundStyle(.primary)
    }
    
    private func updateCacheLimit(_ limit: CacheLimit) {
        let newCacheLimit: UInt
        
        switch limit {
        case .MB250:
            newCacheLimit = 250 * 1024 * 2
            
        case .GB1:
            newCacheLimit = 1000 * 1024 * 2
        }
        
        cache.updateLimit(newCacheLimit)
    }
}

#Preview {
    List {
        CacheLimit()
    }
}
