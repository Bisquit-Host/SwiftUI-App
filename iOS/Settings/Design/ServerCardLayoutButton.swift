import SwiftUI

struct ServerCardLayoutButton: View {
    @State private var sheetServerCardLayout = false
    
    var body: some View {
        Button {
            sheetServerCardLayout = true
        } label: {
            Label {
                Text("Server card layout")
            } icon: {
                Image(systemName: "externaldrive")
                    .foregroundStyle(.blue)
            }
        }
        .foregroundStyle(.foreground)
        .sheet($sheetServerCardLayout) {
            NavigationStack {
                ServerCardLayout()
            }
        }
    }
}
