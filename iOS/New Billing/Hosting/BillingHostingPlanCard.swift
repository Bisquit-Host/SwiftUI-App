import SwiftUI

struct BillingHostingPlanCard: View {
    let plan: BillingHostingPlan
    let priceText: String
    let category: BillingHostingCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .headline()
                    
                    if let cpuName = plan.cpuName {
                        Text(cpuName)
                            .footnote()
                            .secondary()
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(priceText)
                        .semibold()
                    
                    Text("/mo")
                        .footnote()
                        .secondary()
                }
            }
            
            HStack(spacing: 12) {
                spec("cpu", "\(plan.cpu.clean) vCPU")
                spec("memorychip", "\(plan.memoryGB.clean) GB RAM")
                spec("internaldrive", "\(plan.diskGB.clean) GB \(plan.diskType ?? "")".trimmingCharacters(in: .whitespaces))
            }
            
            if let network = plan.networkDescription {
                spec("network", network)
            }
            
            additional
        }
        .padding(16)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.primary.opacity(0.04), lineWidth: 1)
        }
    }
    
    @ViewBuilder
    private var additional: some View {
        HStack(spacing: 12) {
            if let databases = plan.databases {
                spec("externaldrive.fill", "\(databases) DBs")
            }
            
            if let backups = plan.backups {
                spec("clock.arrow.circlepath", "\(backups) backups")
            }
            
            if let allocations = plan.allocations {
                spec("number", "\(allocations) ports")
            }
        }
        
        HStack(spacing: 8) {
            if category == .cloud, plan.windowsAllowed == true {
                tag("Windows available")
            }
            
            if category == .cloud, plan.antiSpoofing == true {
                tag("Anti-spoofing")
            }
        }
    }
    
    private func spec(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .footnote()
                .secondary()
            
            Text(text)
                .footnote()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(.background.opacity(0.6), in: .rect(cornerRadius: 10))
    }
    
    private func tag(_ text: String) -> some View {
        Text(text)
            .footnote()
            .secondary()
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(.background.opacity(0.6), in: .rect(cornerRadius: 10))
    }
}

#Preview {
    BillingHostingPlanCard(plan: .preview, priceText: "₽399", category: .game)
        .padding()
        .darkSchemePreferred()
}
