import SwiftUI
import Kingfisher

struct VDSReinstallSectionOSLogo: View {
    private let category: CloudServiceOSCategory
    
    init(_ category: CloudServiceOSCategory) {
        self.category = category
    }
    
    var body: some View {
        if let urlString = category.logoUrl, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFit()
                .frame(24)
                .clipShape(.rect(cornerRadius: 6))
        } else {
            Image(systemName: "questionmark.square.dashed")
                .resizable()
                .scaledToFit()
                .frame(24)
                .secondary()
        }
    }
}

//#Preview {
//    VDSReinstallSectionOSLogo()
//        .darkSchemePreferred()
//}
