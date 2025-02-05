import ScrechKit
import Kingfisher

struct CacheExpiration: View {
    @Environment(CacheVM.self) private var cache
    
    @AppStorage("cacheExpiration") private var cacheExpiration: CacheExpiration = .month
    
    private let intervals: [CacheExpiration] = [.day, .week, .month, .year, .never]
    
    var body: some View {
        Menu {
            ForEach(intervals, id: \.self) { interval in
                Button(interval.rawValue.capitalized) {
                    cacheExpiration = interval
                    updateCacheExpiration(interval)
                }
            }
        } label: {
            HStack {
                Text("Expiration")
                
                Spacer()
                
#warning("Not localized")
                Text(String(cacheExpiration.rawValue.capitalized))
                
                Image(systemName: "chevron.forward")
                    .secondary()
            }
        }
        .foregroundStyle(.primary)
    }
    
    private func updateCacheExpiration(_ expiration: CacheExpiration) {
        let newCacheExpiration: StorageExpiration
        
        switch expiration {
        case .day: newCacheExpiration = .days(1)
        case .week: newCacheExpiration = .days(7)
        case .month: newCacheExpiration = .days(30)
        case .year: newCacheExpiration = .days(365)
        case .never: newCacheExpiration = .never
        }
        
        cache.updateExpirationTime(to: newCacheExpiration)
    }
}

#Preview {
    List {
        CacheExpiration()
    }
}
