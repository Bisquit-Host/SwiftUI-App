import SwiftUI
import Kingfisher

struct Des_Image: View {
    private var vm: DesImageVM
    @EnvironmentObject private var settings: SettingsStorage
    
    private let id, path, name: String
    
    init(_ id: String,
         path: String,
         name: String,
         model: DesImageVM = DesImageVM("")
    ) {
        self.id = id
        self.path = path
        self.name = name
        self.vm = DesImageVM(id)
    }
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                if let image = vm.cachedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    KFImage(stringToUrl(vm.url))
                        .fade(duration: 0.25)
                        .memoryCacheExpiration(.seconds(300))
                        .diskCacheExpiration(.days(1))
                        .onSuccess { result in
                            KingfisherManager.shared.cache.store(
                                result.image,
                                forKey: path + name
                            )
                            
                            vm.cachedImage = result.image
                        }
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .onAppear {
            vm.downloadImage(path + name)
            vm.loadCachedImage(path + name)
        }
    }    
}
