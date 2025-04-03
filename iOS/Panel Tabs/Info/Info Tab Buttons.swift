import ScrechKit
import PteroNet

struct InfoTabButtons: View {
    private let server: ServerAttributes
    @State private var settingsVM: ServerSettingsVM
    @State private var logVM: LogVM
    @State private var userVM: UsersVM
    @State private var subdomainVM: SubdomainVM
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.settingsVM = ServerSettingsVM(server.id)
        self.logVM = LogVM(server.id)
        self.userVM = UsersVM(server.id)
        self.subdomainVM = SubdomainVM(server.id)
    }
    
    @State private var sheetUsers = false
    @State private var sheetLogs = false
    @State private var sheetSubdomains = false
    
    var body: some View {
        VStack(spacing: 10) {
            Menu {
                Button {
                    sheetUsers = true
                    userVM.sheetInvitation = true
                } label: {
                    Label("New user", systemImage: "person.badge.plus")
                }
            } label: {
                Button {
                    sheetUsers = true
                } label: {
                    VStack(spacing: 12) {
                        if userVM.users.count == 0 {
                            VStack(spacing: 5) {
                                Image(systemName: "person.3.fill")
                                    .foregroundStyle(.tertiary)
                                
                                Text("Users")
                                    .semibold()
                            }
                            .footnote()
                        } else {
                            Text("Users")
                                .footnote(.semibold)
                            
                            HStack {
                                ForEach(userVM.users.prefix(7)) { user in
                                    InfoTabButtonsUserImg(user.image)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.foreground)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.gray.opacity(0.25), lineWidth: 1)
                    }
                }
            } primaryAction: {
                sheetUsers = true
            }
            
            Button {
                sheetLogs = true
            } label: {
                VStack(spacing: 5) {
                    if logVM.logs.isEmpty {
                        Image(systemName: "list.bullet.rectangle.fill")
                            .foregroundStyle(.tertiary)
                        
                        Text("Logs")
                            .semibold()
                    } else {
                        Text("Logs")
                            .semibold()
                            .rounded()
                        
                        if let log = logVM.logs.first {
                            LogCard(log, showInfoButton: false)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        let count = logVM.logs.count
                        
                        if count > 0 {
                            let chevron = Image(systemName: "arrow.right")
                            
                            Text("\(count - 1) more entries \(chevron)")
                                .caption2()
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .footnote()
                .padding()
                .frame(minHeight: 55)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.foreground)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray.opacity(0.25), lineWidth: 1)
                }
            }
            
            Button {
                sheetSubdomains = true
            } label: {
                HStack {
                    if subdomainVM.subdomains.isEmpty {
                        VStack(spacing: 5) {
                            Image(systemName: "globe")
                                .foregroundStyle(.tertiary)
                            
                            Text("Subdomains")
                                .semibold()
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text("Subdomains")
                                .footnote()
                                .secondary()
                                .rounded()
                            
                            ForEach(subdomainVM.subdomains) { subdomain in
                                Text("\(subdomain.subdomain).\(subdomain.domain)")
                                    .monospaced()
                            }
                        }
                        
                        Spacer()
                        
                        let chevron = Image(systemName: "arrow.right")
                        
                        Text("All subdomains \(chevron)")
                            .caption2()
                            .foregroundStyle(.tertiary)
                    }
                }
                .footnote()
                .frame(minHeight: 55)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: subdomainVM.subdomains.isEmpty ? .center : .leading)
                .foregroundStyle(.foreground)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray.opacity(0.25), lineWidth: 1)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .sheet($sheetUsers) {
            UserListParent()
                .environment(userVM)
        }
        .sheet($sheetLogs) {
            LogListParent()
                .environment(logVM)
        }
        .sheet($sheetSubdomains) {
            NavigationView {
                SubdomainList()
            }
            .environment(subdomainVM)
        }
        .task {
            settingsVM.serverName = server.name
            settingsVM.serverDescription = server.description
            
            if !System.lowPowerMode {
                logVM.fetchLogs(true)
                userVM.fetchUsers(true)
                
                Task {
                    await subdomainVM.fetchSubdomains()
                }
            }
        }
    }
}

#Preview {
    InfoTabButtons(PreviewProp.serverAttributes)
}
