import ScrechKit
import Kingfisher

struct CacheExpiration: View {
    private let intervals: [CacheExpiration] = [.day, .week, .month, .year, .never]
    
    @AppStorage("cacheExpiration") private var cacheExpiration: CacheExpiration = .month
    
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
                Text("Cache expiration")
                
                Spacer()
                
                Text(cacheExpiration.rawValue.capitalized)
                
                Image(systemName: "chevron.forward")
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.primary)
    }
    
    func updateCacheExpiration(_ expiration: CacheExpiration) {
        let newCacheExpiration: StorageExpiration
        
        switch expiration {
        case .day: newCacheExpiration = .days(1)
        case .week: newCacheExpiration = .days(7)
        case .month: newCacheExpiration = .days(30)
        case .year: newCacheExpiration = .days(365)
        case .never: newCacheExpiration = .never
        }
        
        CacheVM().updateExpirationTime(to: newCacheExpiration)
    }
}

#Preview {
    List {
        CacheExpiration()
    }
}
