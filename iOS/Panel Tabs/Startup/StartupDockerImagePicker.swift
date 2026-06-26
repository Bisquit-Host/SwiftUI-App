import SwiftUI

struct StartupDockerImagePicker: View {
    @Environment(StartupVM.self) private var vm
    
    init(_ dockerImage: String) {
        currentDockerImage = dockerImage
    }
    
    @State private var currentDockerImage: String
    
    var body: some View {
        Picker("Docker Image", selection: $currentDockerImage) {
            ForEach(vm.sortedDockerImages, id: \.key) { key, value in
                Text(key)
                    .tag(value)
            }
        }
        .listRowBackground(Color.gray.opacity(0.2))
        .onChange(of: currentDockerImage) { _, newDockerImage in
            updateDockerImage(newDockerImage)
        }
    }
    
    private func updateDockerImage(_ newImage: String) {
        Task {
            await vm.updateDockerImage(newImage)
        }
    }
}

#Preview {
    StartupDockerImagePicker("Preview")
}
