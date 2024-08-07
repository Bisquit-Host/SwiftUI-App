import SwiftUI

struct DynamicIslandBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "hammer")
            
            Text("Bisquit.Host")
        }
        .font(.footnote)
        .frame(width: 120, height: 35)
        .background(.orange.gradient)
        .foregroundColor(.white)
        .clipShape(.capsule)
        
        .padding(.top, 12)
        .ignoresSafeArea()
    }
}

#Preview {
    DynamicIslandBadge()
}
