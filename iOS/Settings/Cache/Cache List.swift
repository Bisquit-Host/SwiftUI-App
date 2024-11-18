import SwiftUI

struct CacheList: View {
    @State private var vm = CacheListVM()
    
    var body: some View {
        List {
            Section {
                Text("Retrieved \(vm.images.count) cached images")
            }
            
            ForEach(vm.images) { cache in
                HStack {
                    Image(uiImage: cache.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
                    Spacer()
                    
                    Text(cache.size)
                        .secondary()
                }
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
