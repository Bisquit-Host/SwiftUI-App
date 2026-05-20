import SwiftUI

struct UpdateSheet: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    
    @State private var alertUpdate = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image(systemName: "arrow.down.circle.fill")
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(5, delay: 3)), isActive: !System.lowPowerMode)
                .fontSize(100)
                .foregroundStyle(.white)
                .padding(.bottom, 32)
            
            Text("Update Available")
                .largeTitle(.bold, design: .rounded)
                .foregroundStyle(.white)
                .padding(.bottom, 12)
            
            Text("A new version of the app is available with exciting new features and improvements")
                .semibold()
                .foregroundStyle(.white)
                .padding([.horizontal, .bottom], 32)
            
            VStack(spacing: 16) {
                UpdateSheetButton("Update later") {
                    dismiss()
                }
                
                UpdateSheetButton("View in App Store") {
                    openURL(URL(string: Endpoint.updateApp)!)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            alertUpdate = true
        }
#if os(iOS) || os(visionOS)
        .appStoreOverlay($alertUpdate, id: 1639409934)
#endif
        .background(UpdateSheetBackground())
    }
}
