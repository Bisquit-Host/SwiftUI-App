import ScrechKit

struct ResourceMetricView: View {
    let title: LocalizedStringKey
    let value: String
    let systemImage: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: systemImage)
                .caption2()
                .foregroundStyle(.secondary)
                .lineLimit(1)
            
            Text(value)
                .headline()
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.background.secondary, in: .rect(cornerRadius: 8))
    }
}
