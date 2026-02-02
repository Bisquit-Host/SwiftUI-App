import ScrechKit
import Kingfisher

struct CacheExpiration: View {
    @Environment(CacheVM.self) private var cache
    
    @AppStorage("cacheExpiration") private var cacheExpiration: CacheExpiration = .month
    
    private let intervals: [CacheExpiration] = [
        .month, .year, .never
    ]
    
    var body: some View {
        HStack(spacing: 12) {
            GlassyIcon("clock", tint: .orange)
            
            Text("Expiration")
                .subheadline(.semibold)
            
            Spacer()
            
            Menu {
                ForEach(intervals, id: \.self) { interval in
                    Button(interval.loc) {
                        cacheExpiration = interval
                        updateCacheExpiration(interval)
                    }
                }
            } label: {
                
                Text(cacheExpiration.loc)
                    .secondary()
                
                Image(systemName: "chevron.forward")
                    .caption2(.bold)
                    .tertiary()
            }
            .foregroundStyle(.foreground)
        }
    }
    
    private func updateCacheExpiration(_ expiration: CacheExpiration) {
        let newCacheExpiration: StorageExpiration
        
        switch expiration {
        case .month: newCacheExpiration = .days(30)
        case .year:  newCacheExpiration = .days(365)
        case .never: newCacheExpiration = .never
        }
        
        cache.updateExpirationTime(to: newCacheExpiration)
    }
}

#Preview {
    List {
        CacheExpiration()
    }
    .darkSchemePreferred()
    .environment(CacheVM())
}
