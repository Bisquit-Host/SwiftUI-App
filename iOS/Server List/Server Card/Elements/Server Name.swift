import SwiftUI

struct ServerName: View {
    private let name: String
    private let color: Color
    
    init(_ name: String, color: Color) {
        self.name = name
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text(name)
                .headline()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)
        }
    }
}
