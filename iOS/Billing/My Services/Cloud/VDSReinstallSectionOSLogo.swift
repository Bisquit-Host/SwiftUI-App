import SwiftUI
import Kingfisher

struct VDSReinstallSectionOSLogo: View {
    private let category: CloudServiceOSCategory
    private let size: CGFloat
    
    init(_ category: CloudServiceOSCategory, size: CGFloat = 24) {
        self.category = category
        self.size = size
    }
    
    var body: some View {
        if let assetName {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(size)
        } else if let urlString = category.logoUrl, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFit()
                .frame(size)
        } else {
            Image(systemName: "questionmark.square.dashed")
                .resizable()
                .scaledToFit()
                .frame(size)
                .secondary()
        }
    }
    
    private var assetName: String? {
        switch category.name.lowercased() {
        case "windows": "Windows"
        case "ubuntu": "Ubuntu"
        case "freebsd": "FreeBSD"
        case "docker": "Docker"
        case "astra linux": "Astra Linux"
        case "alma linux": "Alma Linux"
        case "rocky linux": "Rocky Linux"
        case "centos": "CentOS"
        case "oracle linux": "Oracle Linux"
        case "debian": "Debian"
        default: nil
        }
    }
}

//#Preview {
//    VDSReinstallSectionOSLogo()
//        .darkSchemePreferred()
//}
