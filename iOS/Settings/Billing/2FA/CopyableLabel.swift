import SwiftUI

struct CopyableLabel: View {
    private let value: String
    
    init(_ value: String) {
        self.value = value
    }
    
    var body: some View {
        HStack {
            Text(value)
                .monospaced()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            Button {
                UIPasteboard.general.string = value
                SystemAlert.copied("Copied")
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 10))
    }
}
