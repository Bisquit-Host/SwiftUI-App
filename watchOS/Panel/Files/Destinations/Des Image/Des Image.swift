import SwiftUI
import Kingfisher

struct ImageFile: View {
    private var vm: ImageFileVM
    
    private let id, name, path: String
    
    init(_ id: String, name: String, at path: String) {
        self.id = id
        self.path = path
        self.name = name
        self.vm = ImageFileVM(id)
    }
    
    var body: some View {
        VStack {
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
        .navigationTitle(name)
        .task {
            vm.loadCachedImage(path + name)
            await vm.downloadImage(path + name)
        }
    }
}
