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
                    Text("Cancel")
                        .padding()
                        .foregroundStyle(.red)
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
                    Text("Live Activity")
                        .padding()
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
    }
}

#Preview {
    InfoTabLAButton(sampleJSON(.serverListAttributes))
}
