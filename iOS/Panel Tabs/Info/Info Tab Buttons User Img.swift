import SwiftUI
import Kingfisher

struct InfoTabButtonsUserImg: View {
    private let img: String
    
    init(_ img: String) {
        self.img = img
    }
    
    var body: some View {
        if let url = URL(string: img) {
            KFImage(url)
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(.circle)
                .overlay {
                    Circle()
                        .stroke(.gray.opacity(0.25), lineWidth: 1)
                }
        }
    }
}

//#Preview {
//    InfoTabButtonsUserImg()
//}
