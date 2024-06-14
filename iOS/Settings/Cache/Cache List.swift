import SwiftUI

struct CacheList: View {
    private var vm = CacheListVM()
    
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
        .task {
            vm.retrieveAllCachedImages { images in
                print("Retrieved \(images.count) cached images")
            }
        }
    }
}

#Preview {
    CacheList()
}
