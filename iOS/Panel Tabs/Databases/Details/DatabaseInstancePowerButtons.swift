import ScrechKit

struct DatabaseInstancePowerButtons: View {
    @Environment(DatabaseInstanceDetailsVM.self) private var vm
    
    @State private var alertKill = false
    
    var body: some View {
        HStack {
            AsyncButton("Start", systemImage: "play") {
                await vm.power(.start)
            }
            .disabled(vm.state != .offline)
            
            AsyncButton("Restart", systemImage: "arrow.clockwise") {
                await vm.power(.restart)
            }
            .disabled(vm.isOffline)
            
            if vm.state == .stopping {
                Button("Kill", systemImage: "xmark.octagon", role: .destructive) {
                    alertKill = true
                }
            } else {
                AsyncButton("Stop", systemImage: "stop", role: .destructive) {
                    await vm.power(.stop)
                }
                .disabled(vm.isOffline)
            }
        }
        .buttonStyle(.bordered)
        .labelStyle(.iconOnly)
        .frame(maxWidth: .infinity)
        .alert("Force Kill", isPresented: $alertKill) {
            AsyncButton("Kill", role: .destructive) {
                await vm.power(.kill)
            }
        } message: {
            Text("Killing the database may result in data corruption")
        }
    }
}
