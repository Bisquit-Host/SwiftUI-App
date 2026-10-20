import SwiftUI

struct LocationSoldOutBanner: View {
    private let hasAlternatives: Bool

    init(hasAlternatives: Bool) {
        self.hasAlternatives = hasAlternatives
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .title3()
                .secondary()

            VStack(alignment: .leading, spacing: 2) {
                Text("This location is sold out")
                    .subheadline(.semibold)

                Text(hasAlternatives ? "Pick another location or check back later" : "Check back later")
                    .footnote()
                    .secondary()
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.fill.quaternary, in: .rect(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    LocationSoldOutBanner(hasAlternatives: true)
        .padding()
        .darkSchemePreferred()
}
