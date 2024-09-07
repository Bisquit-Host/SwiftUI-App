import SwiftUI

struct CacheList: View {
    @State private var vm = CacheListVM()
    
    var body: some View {
        List {
            Section {
                Text("Retrieved \(vm.images.count) cached images")
            }
            
            ForEach(vm.images, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }
        }
        .refreshableTask {
            vm.retrieveAllCachedImages()
        }
    }
}

#Preview {
    CacheList()
}
