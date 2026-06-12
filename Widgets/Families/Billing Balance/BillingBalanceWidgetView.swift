import SwiftUI
import WidgetKit

struct BillingBalanceWidgetView: View {
    private let entry: BillingBalanceEntry
    
    init(_ entry: BillingBalanceEntry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "banknote.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                
                Spacer()
                
                Button("Refresh", systemImage: "arrow.clockwise", intent: RefreshIntent())
                    .font(.caption)
                    .labelStyle(.iconOnly)
            }
            
            Spacer()
            
            Text("Total balance")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(entry.balance)
                .font(.title)
                .bold()
                .minimumScaleFactor(0.65)
                .lineLimit(1)
            
            Text(entry.date, format: .dateTime.hour().minute())
                .font(.caption2)
                .foregroundStyle(.tertiary)
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
