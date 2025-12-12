import SwiftUI

struct VDSPowerSection: View {
    let serviceId: Int
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Power")
                .subheadline(.semibold)
            
            HStack(spacing: 12) {
                powerButton("Start", symbol: "play.fill", tint: .green) {
                    await vm.power("start", serviceId: serviceId)
                }
                
                powerButton("Restart", symbol: "gobackward", tint: .orange) {
                    await vm.power("restart", serviceId: serviceId)
                }
                
                powerButton("Stop", symbol: "stop.fill", tint: .red) {
                    await vm.power("stop", serviceId: serviceId)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func powerButton(_ title: String, symbol: String, tint: Color, action: @escaping () async -> Void) -> some View {
        Button {
            Task { await action() }
        } label: {
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
}
