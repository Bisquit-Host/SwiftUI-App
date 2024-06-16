import ScrechKit
import PteroNet

struct ServerCard: View {
    @State private var vm: ServerCardVM
    @EnvironmentObject private var settings: SettingsStorage
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = ServerCardVM(server.id)
    }
    
    @Namespace private var animation
    private let bounds = UIScreen.main.bounds
    
    var body: some View {
        let name = server.name.replacing(" ", with: "")
        let limits = server.limits
        
        VStack {
            switch settings.designCode {
            case 0:
                VStack {
                    ServerCardNaStatus(name, color: vm.stateColor)
                        .matchedEffect("name", in: animation)
                    
                    if vm.stateColor != .red {
                        HStack(spacing: 20) {
                            RegularGauge(.cpu,
                                         value: vm.cpuUsage,
                                         limit: limits.cpu,
                                         isRedacted: vm.isLoading)
                            
                            RegularGauge(.ram,
                                         value: vm.ramUsage,
                                         limit: limits.memory,
                                         isRedacted: vm.isLoading)
                        }
                        .matchedEffect("RAM_CPU", in: animation)
                    }
                    
                    DiskGauge(vm.diskUsage,
                              limit: limits.disk,
                              isRedacted: vm.isLoading)
                    .matchedEffect("disk", in: animation)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 35))
                
            case 1:
                HStack {
                    VStack {
                        ServerCardNaStatus(name, color: vm.stateColor)
                            .matchedEffect("name", in: animation)
                        
                        DiskGauge(vm.diskUsage,
                                  limit: limits.disk,
                                  isRedacted: vm.isLoading)
                        .padding(.top, 4)
                        .matchedEffect("disk", in: animation)
                    }
                    
                    if vm.stateColor != .red {
                        HStack {
                            RegularGauge(.cpu,
                                         value: vm.cpuUsage,
                                         limit: limits.cpu,
                                         isRedacted: vm.isLoading)
                            
                            RegularGauge(.ram,
                                         value: vm.ramUsage,
                                         limit: limits.memory,
                                         isRedacted: vm.isLoading)
                        }
                        .matchedEffect("RAM_CPU", in: animation)
                    }
                }
                .frame(height: 90)
                .padding(.horizontal)
                .background(.ultraThinMaterial,
                            in: .rect(cornerRadius: 25))
                //            case 2:
                //                HStack {
                //                    VStack {
                //
                //                    }
                //
                //                    VStack {
                //                        HStack {
                //                            ServerCard_Gauge("Backups", value: , limit: <#T##Double#>, isRedacted: <#T##Bool#>)
                //                            //RegularGauge("DB", isRedacted: vm.isLoadingData, value: vm.ram_usage, limit: ram_limit)
                //                        }
                //
                //                        HStack {
                //                RegularGauge(
                //                    .cpu,
                //                    value: vm.cpu_usage,
                //                    limit: limits.cpu,
                //                    isRedacted: vm.isLoadingData
                //                )
                //                RegularGauge(
                //                    .ram,
                //                    value: vm.ram_usage,
                //                    limit: limits.memory,
                //                    isRedacted: vm.isLoadingData
                //                )
                //                        }
                //                        .matchedEffect("RAM_CPU", in: animation)
                //                    }
                //                }
            default: EmptyView()
            }
        }
        .task {
            vm.fetchServerUsage()
        }
        .onChange(of: settings.updateServers) {
            vm.fetchServerUsage()
        }
    }
}

#Preview {
    LazyVGrid(
        columns: [
            GridItem(.adaptive(minimum: 160, maximum: 400))
        ],
        spacing: 8
    ) {
        ServerCard(
            sampleJSON(.serverListAttributes)
        )
        
        ServerCard(
            sampleJSON(.serverListAttributes)
        )
        
        ServerCard(
            sampleJSON(.serverListAttributes)
        )
        
        ServerCard(
            sampleJSON(.serverListAttributes)
        )
    }
    .padding(5)
    .environmentObject(SettingsStorage())
}
