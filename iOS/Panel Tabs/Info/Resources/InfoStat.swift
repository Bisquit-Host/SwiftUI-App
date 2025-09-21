import SwiftUI

struct InfoStat: View {
    private let param: LocalizedStringResource
    private var value: String
    private var alignment: HorizontalAlignment
    
    init(
        _ param: LocalizedStringResource,
        value: String,
        alignment: HorizontalAlignment = .center
    ) {
        self.param = param
        self.value = value
        self.alignment = alignment
    }
    
    var body: some View {
        VStack(alignment: alignment) {
            Text(param)
                .footnote()
                .secondary()
            
            Text(value)
                .monospaced()
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
}

#Preview {
    InfoStat("Memory", value: "16213123%")
}
