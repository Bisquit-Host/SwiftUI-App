import ScrechKit

struct CacheLimit: View {
    @Environment(CacheVM.self) private var cache
    
    @AppStorage("cacheLimit") private var cacheLimit: CacheLimit = .GB1
    
    private let limits: [CacheLimit] = [.MB50, .MB250, .GB1]
    
    var body: some View {
        Menu {
            ForEach(limits, id: \.self) { limit in
                Button(limit.rawValue) {
                    cacheLimit = limit
                    updateCacheLimit(limit)
                }
            }
        } label: {
            HStack {
                Text("Cache limit")
                
                Spacer()
                
                Text(cacheLimit.rawValue)
                
                Image(systemName: "chevron.forward")
                    .secondary()
            }
        }
        .foregroundStyle(.primary)
    }
    
    func updateCacheLimit(_ limit: CacheLimit) {
        let newCacheLimit: UInt
        
        switch limit {
        case .MB50:
            newCacheLimit = 50 * 1024 * 2
            
        case .MB250:
            newCacheLimit = 250 * 1024 * 2
            
        case .GB1:
            newCacheLimit = 1000 * 1024 * 2
        }
        
        cache.updateLimit(to: newCacheLimit)
    }
}

#Preview {
    List {
        CacheLimit()
    }
}
