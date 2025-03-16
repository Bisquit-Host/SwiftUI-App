import SwiftUI
import PteroNet

struct InfoTabLAButton: View {
    @State private var la = LiveActivity()
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        VStack {
            if la.activityViewState?.activityState == .active {
                Button {
                    la.stopAllLiveActivities()
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "clock.badge.fill")
                            .foregroundStyle(.tertiary)
                        
                        Text("Cancel")
                            .semibold()
                    }
                    .footnote()
                    .foregroundStyle(.red)
                    .padding(.horizontal)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial, in: .capsule)
                    .overlay {
                        Capsule()
                            .stroke(.gray.opacity(0.25), lineWidth: 1)
                    }
                }
            } else {
                Button {
                    la.stopAllLiveActivities()
                    la.startLiveActivity(server)
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "clock.badge.fill")
                            .foregroundStyle(.tertiary)
                        
                        Text("Live Activity")
                            .semibold()
                    }
                    .footnote()
                    .padding(.horizontal)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial, in: .capsule)
                    .overlay {
                        Capsule()
                            .stroke(.gray.opacity(0.25), lineWidth: 1)
                    }
                }
            }
        }
        .title2(.semibold, design: .rounded)
        .foregroundStyle(.foreground)
        .animation(.default, value: la.activityViewState?.activityState)
    }
}

#Preview {
    InfoTabLAButton(sampleJSON(.serverListAttributes))
}
