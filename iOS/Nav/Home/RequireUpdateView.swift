import SwiftUI

struct RequireUpdateView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    
    @State private var alertUpdate = false
    
    private var gradientColors: [Color] {
        if colorScheme == .dark {
            [.orange.opacity(0.35), .orange.opacity(0.5), .orange.opacity(0.4)]
        } else {
            [.orange.opacity(0.7), .orange, .orange.opacity(0.9)]
        }
    }
    
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
                Button {
                    openURL(URL(string: Endpoint.updateApp)!)
                } label: {
                    Text("View in App Store")
                        .title3(.semibold, design: .rounded)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                }
#if !os(visionOS)
                .buttonStyle(.glassProminent)
#endif
                .tint(.orange.opacity(0.5))
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
        .background {
            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        }
    }
}
