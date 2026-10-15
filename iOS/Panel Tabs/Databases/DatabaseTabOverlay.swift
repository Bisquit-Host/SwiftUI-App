import ScrechKit

struct DatabaseTabOverlay: View {
    @Environment(DatabaseInstanceVM.self) private var vm
    
    var body: some View {
        if vm.isLoadingInstances && vm.instances.isEmpty {
            ProgressView()
        } else if vm.hasFinishedLoadingInstances && vm.instances.isEmpty {
            ContentUnavailableView(
                "No managed databases",
                systemImage: "cylinder.split.1x2",
                description: Text("Managed databases run in their own container with dedicated resources")
            )
        }
    }
}
