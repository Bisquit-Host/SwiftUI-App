import ScrechKit

struct HostingPlanCardKeySpec: View {
    private let icon, value: String
    private let label: Text
    private let category: BillingHostingCategory

    init(_ icon: String, value: String, label: Text, in category: BillingHostingCategory) {
        self.icon = icon
        self.value = value
        self.label = label
        self.category = category
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .footnote(.semibold)
                .foregroundStyle(category.tint)

            Text(value)
                .headline()
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            label
                .caption2()
                .secondary()
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.fill.quaternary, in: .rect(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }
}
