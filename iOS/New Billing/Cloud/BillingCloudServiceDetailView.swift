import Charts
import SwiftUI

struct BillingCloudServiceDetailView: View {
    @State private var vm = BillingCloudServiceDetailVM()
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    let serviceId: Int
    
    @State private var pendingName = ""
    @State private var rootPassword = ""
    @State private var selectedOsId: Int?
    @State private var showVnc = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let service = vm.service {
                    header(service)
                    infoSection(service)
                    powerSection(service)
                    passwordSection(service)
                    reinstallSection(service)
                    chartsSection()
                    historySection()
                } else if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                }
                
                if let message = vm.actionMessage {
                    Text(message)
                        .footnote()
                        .foregroundStyle(.green)
                }
                
                if let error = vm.lastError {
                    Text(error)
                        .footnote()
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Service #\(serviceId)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if vm.isPerformingAction {
                ProgressView()
            }
        }
        .task {
            await vm.load(serviceId: serviceId)
        }
        .refreshable {
            await vm.load(serviceId: serviceId)
        }
        .onChange(of: vm.service?.id) { _, _ in
            if let service = vm.service {
                pendingName = service.name
            }
            rootPassword = ""
        }
        .onChange(of: vm.osOptions.count) { _, _ in
            if selectedOsId == nil {
                selectedOsId = flatOsOptions().first?.0
            }
        }
        .safariCover($showVnc, url: "https://test-my.bisquit.host/cloud/\(serviceId)?tab=console")
    }
    
    // MARK: - Sections
    
    private func header(_ service: BillingCloudServiceDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text(service.name)
                    .title3(.bold)
                
                Spacer()
                
                Capsule()
                    .fill(service.state.color.opacity(0.15))
                    .overlay {
                        Text(service.state.title)
                            .footnote(.semibold)
                            .foregroundStyle(service.state.color)
                            .padding(.horizontal, 10)
                    }
                    .frame(height: 30)
            }
            
            HStack(spacing: 10) {
                Text("IP: \(service.ip ?? "n/a")")
                    .footnote()
                    .secondary()
                
                if let system = service.system {
                    Text("• \(system)")
                        .footnote()
                        .secondary()
                }

                Button {
                    showVnc = true
                } label: {
                    Label("Console", systemImage: "display")
                        .footnote()
                        .foregroundStyle(.blue)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("New name", text: $pendingName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                Button {
                    Task { await vm.rename(pendingName.isEmpty ? service.name : pendingName, serviceId: service.id) }
                } label: {
                    Text("Change name")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isPerformingAction)
            }
            .padding()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
        }
    }
    
    private func infoSection(_ service: BillingCloudServiceDetails) -> some View {
        BillingSectionCard("Details") {
            VStack(alignment: .leading, spacing: 10) {
                row(title: "Package", value: service.packageInfo.name)
                row(title: "CPU", value: "\(String(format: "%.1f", service.packageInfo.cpu)) vCPU \(service.packageInfo.cpuName ?? "")")
                row(title: "RAM", value: "\(String(format: "%.1f", service.packageInfo.memory)) GB")
                row(title: "Disk", value: "\(String(format: "%.0f", service.packageInfo.disk)) GB \(service.packageInfo.diskType ?? "")")
                row(title: "Location", value: service.location.name)
                
                if let expires = service.expiresAt {
                    row(title: "Expires", value: expires.formatted(date: .numeric, time: .shortened))
                }
            }
        }
    }
    
    private func powerSection(_ service: BillingCloudServiceDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Power")
                .subheadline(.semibold)
            
            HStack(spacing: 12) {
                powerButton("Start", symbol: "play.fill", tint: .green) {
                    Task { await vm.power("start", serviceId: service.id) }
                }
                
                powerButton("Restart", symbol: "gobackward", tint: .orange) {
                    Task { await vm.power("restart", serviceId: service.id) }
                }
                
                powerButton("Stop", symbol: "stop.fill", tint: .red) {
                    Task { await vm.power("stop", serviceId: service.id) }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func passwordSection(_ service: BillingCloudServiceDetails) -> some View {
        BillingSectionCard("Root password") {
            VStack(alignment: .leading, spacing: 8) {
                SecureField("New password", text: $rootPassword)
                
                Button {
                    Task { await vm.changePassword(rootPassword, serviceId: service.id) }
                } label: {
                    Text("Update password")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isPerformingAction || rootPassword.count < 8)
            }
        }
    }
    
    private func reinstallSection(_ service: BillingCloudServiceDetails) -> some View {
        BillingSectionCard("Reinstall OS") {
            VStack(alignment: .leading, spacing: 8) {
                Picker("OS", selection: $selectedOsId) {
                    ForEach(flatOsOptions(), id: \.0) { os in
                        Text(os.1)
                            .tag(Optional(os.0))
                    }
                }
                .pickerStyle(.navigationLink)
                
                Button(role: .destructive) {
                    if let osId = selectedOsId {
                        Task { await vm.reinstall(osId: osId, serviceId: service.id) }
                    }
                } label: {
                    Text("Reinstall")
                        .frame(maxWidth: .infinity)
                }
                .disabled(selectedOsId == nil || vm.isPerformingAction)
            }
        }
    }
    
    private func chartsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monitoring")
                .subheadline(.semibold)
            
            if let charts = vm.charts {
                VStack(alignment: .leading, spacing: 12) {
                    Chart(charts.cpu) {
                        LineMark(
                            x: .value("Time", $0.timestamp),
                            y: .value("CPU", $0.cpuLoad)
                        )
                        .foregroundStyle(.blue)
                    }
                    .frame(height: 180)
                    .chartYScale(domain: 0...100)
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    
                    Chart(charts.memory) {
                        LineMark(
                            x: .value("Time", $0.timestamp),
                            y: .value("RAM", $0.memoryUsage)
                        )
                        .foregroundStyle(.green)
                    }
                    .frame(height: 180)
                    .chartXAxis(.hidden)
                    
                    Chart {
                        ForEach(charts.networkInput) {
                            LineMark(
                                x: .value("Time", $0.timestamp),
                                y: .value("In", $0.value)
                            )
                            .foregroundStyle(.blue)
                        }
                        ForEach(charts.networkOutput) {
                            LineMark(
                                x: .value("Time", $0.timestamp),
                                y: .value("Out", $0.value)
                            )
                            .foregroundStyle(.orange)
                        }
                    }
                    .frame(height: 180)
                    .chartXAxis(.hidden)
                }
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
            } else {
                Text("No metrics yet")
                    .secondary()
                    .footnote()
            }
        }
    }
    
    private func historySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Action history")
                .subheadline(.semibold)
            
            if vm.history.isEmpty {
                Text("No actions yet")
                    .secondary()
                    .footnote()
            } else {
                ForEach(vm.history) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.type)
                                .subheadline(.semibold)
                            
                            Text(item.state)
                                .footnote()
                                .secondary()
                        }
                        
                        Spacer()
                        
                        if let date = item.date {
                            Text(date.formatted(date: .numeric, time: .shortened))
                                .footnote()
                                .secondary()
                        }
                    }
                    .padding(.vertical, 6)
                    .overlay {
                        Divider()
                            .offset(y: 14)
                            .opacity(item.id == vm.history.last?.id ? 0 : 1)
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func row(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .footnote()
                .secondary()
            Spacer()
            Text(value)
                .footnote()
        }
    }
    
    private func powerButton(_ title: String, symbol: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: symbol)
                Text(title)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(tint.opacity(0.12), in: .capsule)
        }
        .buttonStyle(.plain)
        .disabled(vm.isPerformingAction)
    }
    
    private func flatOsOptions() -> [(Int, String)] {
        vm.osOptions
            .flatMap { category in
                category.os.map { ($0.id, "\(category.name) \($0.version ?? "")") }
            }
    }
}

#Preview {
    NavigationStack {
        BillingCloudServiceDetailView(serviceId: 1)
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
