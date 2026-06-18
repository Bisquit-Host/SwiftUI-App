import ScrechKit
import WidgetKit

struct BillingBalanceWidgetView: View {
    private let entry: BillingBalanceEntry
    
    init(_ entry: BillingBalanceEntry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button("Top-up", systemImage: "plus", intent: OpenBalanceTopupIntent())
                    .labelStyle(.iconOnly)
                    .buttonBorderShape(.circle)
                    .tint(.yellow)
                
                Spacer()
                
                Button("Refresh", systemImage: "arrow.clockwise", intent: RefreshIntent())
                    .labelStyle(.iconOnly)
                    .buttonBorderShape(.circle)
            }
            
            Spacer()
            
            Text(entry.date, format: .dateTime.hour().minute())
                .caption2()
                .foregroundStyle(.tertiary)
            
            Text("Total balance")
                .secondary()
            
            Text(entry.balance)
                .title(.bold)
                .minimumScaleFactor(0.65)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

#Preview(as: .systemSmall) {
    BillingBalanceWidget()
} timeline: {
    BillingBalanceEntry(date: .now, balance: "€ 12.50", state: .loaded)
}
