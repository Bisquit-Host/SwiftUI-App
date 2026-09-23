import ScrechKit

struct ServerSettingsReinstall: View {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    @State private var alertReinstall = false
    
    var body: some View {
        Section {
            Button(role: .destructive) {
                alertReinstall = true
            } label: {
                HStack {
                    Text("Reinstall")
                    
                    Spacer()
                    
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
            .alert("Reinstall Server", isPresented: $alertReinstall) {
                AsyncButton("Reinstall", role: .destructive) {
                    await CalagopusNet.reinstallServer(id) {
                        SystemAlert.reinstalled()
                    }
                }
            } message: {
                Text("Reinstalling your server will stop it, and then re-run the installation script that initially set it. Some files may be deleted or modified during this process, please back up your data before continuing")
            }
        }
    }
}

#Preview {
    ServerSettingsReinstall("")
        .darkSchemePreferred()
}
