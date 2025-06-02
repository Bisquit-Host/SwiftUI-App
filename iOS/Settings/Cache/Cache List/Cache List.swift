import SwiftUI

struct CacheList: View {
    @State private var vm = CacheListVM()
    
    var body: some View {
        Section("\(vm.images.count) images") {
            ForEach(vm.images) { cache in
                CacheCard(cache)
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
