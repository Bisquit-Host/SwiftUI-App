import SwiftUI

struct CacheList: View {
    @State private var vm = CacheListVM()
    
    private let columns = [
        GridItem(.adaptive(minimum: 120))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(vm.images) {
                    CacheCard($0)
                }
            }
        }
        .navigationTitle("Cache")
        .navigationSubtitle("\(vm.images.count) images")
        .refreshableTask {
            vm.retrieveAllCachedImages()
        }
    }
}

#Preview {
    NavigationStack {
        CacheList()
    }
}
