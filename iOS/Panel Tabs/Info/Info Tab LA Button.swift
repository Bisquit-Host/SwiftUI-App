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
                        .foregroundStyle(.red)
                        .frame(height: 25)
                        .padding()
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                }
            } else {
                Button {
                    la.stopAllLiveActivities()
                    la.startLiveActivity(server)
                } label: {
                    Text("Live Activity")
                        .frame(height: 25)
                        .padding()
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                }
            }
        }
        .title2(.semibold, design: .rounded)
        .foregroundStyle(.foreground)
        .overlay(alignment: .topTrailing) {
            Text("Beta")
                .footnote(.bold, design: .rounded)
                .foregroundStyle(.white.gradient)
                .padding(.horizontal, 4)
                .background(.blue.gradient, in: .capsule)
                .padding(-6)
        }
    }
}

#Preview {
    InfoTabLAButton(sampleJSON(.serverListAttributes))
}
