import SwiftUI

struct VDSPowerSection: View {
    let serviceId: Int
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Power")
                .subheadline(.semibold)
            
            HStack(spacing: 12) {
                VDSPowerButton("Start", symbol: "play.fill", tint: .green) {
                    await vm.power("start", serviceId: serviceId)
                }
                
                VDSPowerButton("Restart", symbol: "gobackward", tint: .orange) {
                    await vm.power("restart", serviceId: serviceId)
                }
                
                VDSPowerButton("Stop", symbol: "stop.fill", tint: .red) {
                    await vm.power("stop", serviceId: serviceId)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
