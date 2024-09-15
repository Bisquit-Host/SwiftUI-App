import SwiftUI

struct CryptoPriceWidgetView: View {
    private let entry: ResourcesUsageEntry
    
    init(_ entry: ResourcesUsageEntry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(entry.name)
                    .title(.bold)
                
                Text(entry.id)
                    .footnote()
            }
            
            Text(entry.state)
                .caption2()
                .padding(.bottom, 8)
            
            Text(entry.test?.usage.cpu.description ?? "Fuck")
            
            Text(entry.date, format: .dateTime.minute().second())
                .footnote()
            
            Button("Update", intent: RefreshIntent())
        }
        .containerBackground(for: .widget) {}
    }
}
