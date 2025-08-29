import SwiftUI

struct Server: Identifiable {
    let id = UUID()
    
    let name: String
    let description: String
    let cpuUsage: Double
    let ramUsage: Double
    let diskUsage: Double
    let status: ServerStatus
}

enum ServerStatus {
    case online, warning, offline, suspended
    
    var color: Color {
        switch self {
        case .online: .green
        case .warning: .orange
        case .offline: .red
        case .suspended: .white
        }
    }
}

struct ContentView: View {
    private let servers = [
        Server(name: "Web Server 01", description: "Main production server", cpuUsage: 0.45, ramUsage: 0.68, diskUsage: 0.23, status: .online),
        Server(name: "Database Primary", description: "PostgreSQL cluster master", cpuUsage: 0.78, ramUsage: 0.85, diskUsage: 0.67, status: .offline),
        Server(name: "API Gateway", description: "Load balancer and proxy", cpuUsage: 0.32, ramUsage: 0.54, diskUsage: 0.41, status: .warning),
        Server(name: "Cache Server", description: "Redis memory cache", cpuUsage: 0.15, ramUsage: 0.92, diskUsage: 0.18, status: .suspended),
        Server(name: "Backup Node", description: "Disaster recovery system", cpuUsage: 0.08, ramUsage: 0.34, diskUsage: 0.89, status: .offline),
        Server(name: "Analytics DB", description: "Data warehouse server", cpuUsage: 0.56, ramUsage: 0.71, diskUsage: 0.78, status: .online)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(servers) {
                        NewServerCard($0)
                    }
                }
                .padding()
            }
            .scrollIndicators(.never)
            .background {
                LinearGradient(
                    gradient: Gradient(colors: [
                        .blue.opacity(0.1),
                        .purple.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
        }
    }
}

struct NewServerCard: View {
    private let server: Server
    
    init(_ server: Server) {
        self.server = server
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if server.status != .suspended {
                            Circle()
                                .fill(server.status.color.gradient)
                                .frame(10)
                        }
                        
                        Text(server.name)
                            .headline()
                            .semibold()
                    }
                    
                    Text(server.description)
                        .subheadline()
                        .secondary()
                }
                
                Spacer()
                
                if server.status == .suspended {
                    Image(systemName: "snowflake")
                        .largeTitle()
                }
            }
            
            if server.status != .suspended {
                VStack(spacing: 12) {
                    if server.status != .offline {
                        MetricGauge(
                            title: "CPU",
                            value: server.cpuUsage,
                            color: .blue,
                            icon: "cpu"
                        )
                        
                        MetricGauge(
                            title: "RAM",
                            value: server.ramUsage,
                            color: .green,
                            icon: "memorychip"
                        )
                    }
                    
                    MetricGauge(
                        title: "Disk",
                        value: server.diskUsage,
                        color: .orange,
                        icon: "internaldrive"
                    )
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        }
    }
}

struct MetricGauge: View {
    let title: String
    let value: Double
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .fontSize(16)
                .fontWeight(.medium)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .fontSize(14)
                .fontWeight(.medium)
                .frame(width: 40, alignment: .leading)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.ultraThinMaterial)
                        .frame(height: 8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white.opacity(0.2), lineWidth: 0.5)
                        }
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.8),
                                    color
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * value, height: 8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white.opacity(0.3), lineWidth: 0.5)
                        }
                }
            }
            .frame(height: 8)
            
            Text("\(Int(value * 100))%")
                .monospacedDigit()
                .secondary()
                .fontSize(12)
                .fontWeight(.medium)
                .frame(width: 35, alignment: .trailing)
        }
    }
}

#Preview {
    ContentView()
}
