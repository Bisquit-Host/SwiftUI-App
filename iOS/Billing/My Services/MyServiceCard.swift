import ScrechKit

struct MyServiceCard: View {
    @State private var cardVM = MyServiceCardVM()
    @Environment(DashboardVM.self) private var vm
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    private let service: BillingMyService
    
    init(_ service: BillingMyService) {
        self.service = service
    }
    
    @State private var alertRename = false
    
    var body: some View {
        NavigationLink {
            BillingMyServiceDestinationView(service: service)
                .environment(vm)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    if differentiateWithoutColor {
                        Text(service.state.title.lowercased().capitalized)
                    }
                    
                    HStack {
                        if !differentiateWithoutColor {
                            PulseCircle(service.state.color)
                        }
                        
                        Text(service.name)
                            .subheadline(.semibold)
                    }
                    
                    HStack(spacing: 6) {
                        MyServiceFlagImage(service.flagUrl)
                        
                        Text(service.location)
                            .footnote()
                            .secondary()
                        
                        if let system = service.system {
                            Text("• \(system)")
                                .footnote()
                                .secondary()
                        }
                    }
                    
                    if let ip = service.ip {
                        Label(ip, systemImage: "network")
                            .footnote()
                            .secondary()
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 6)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .dashboardButtonCardBackground()
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Rename", systemImage: "pencil") {
                cardVM.prepareRename(for: service)
                alertRename = true
            }
            .disabled(cardVM.isRenaming)
        }
        .alert("Rename service", isPresented: $alertRename) {
            TextField("New name", text: $cardVM.newName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            AsyncButton("Save", role: .confirm) {
                await cardVM.rename(service: service)
            }
            .disabled(cardVM.isRenaming)
            
            Button("Cancel", role: .cancel) {}
        }
    }
}
