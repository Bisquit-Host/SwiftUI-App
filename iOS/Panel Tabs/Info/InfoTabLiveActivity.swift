import ScrechKit
import Calagopus

struct InfoTabLiveActivity: View {
    @State private var la = LiveActivity()
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        let isActive = la.activityViewState?.activityState == .active
        
        SFButton("clock.badge") {
            if isActive {
                la.stopAllLiveActivities()
            } else {
                la.stopAllLiveActivities()
                
                Task {
                    await la.startLiveActivity(server)
                }
            }
        }
        .symbolVariant(isActive ? .fill : .none)
        .foregroundStyle(isActive ? .red : .primary)
        .animation(.default, value: la.activityViewState?.activityState)
        
        //        VStack {
        //            if isActive {
        //                Button {
        //                    la.stopAllLiveActivities()
        //                } label: {
        //                    VStack(spacing: 5) {
        //                        Image(systemName: "clock.badge.fill")
        //                            .tertiary()
        //
        //                        Text("Cancel")
        //                            .semibold()
        //                    }
        //                    .footnote()
        //                    .foregroundStyle(.red)
        //                    .padding(.horizontal)
        //                    .frame(height: 55)
        //                    .frame(maxWidth: .infinity)
        //                    .background(.ultraThinMaterial, in: .capsule)
        //                    .overlay {
        //                        Capsule()
        //                            .stroke(.gray.opacity(0.25), lineWidth: 1)
        //                    }
        //                }
        //            } else {
        //                Button {
        //                    la.stopAllLiveActivities()
        //                    la.startLiveActivity(server)
        //                } label: {
        //                    VStack(spacing: 5) {
        //                        Image(systemName: "clock.badge.fill")
        //                            .tertiary()
        //
        //                        Text("Live Activity")
        //                            .semibold()
        //                    }
        //                    .footnote()
        //                    .padding(.horizontal)
        //                    .frame(height: 55)
        //                    .frame(maxWidth: .infinity)
        //                    .background(.ultraThinMaterial, in: .capsule)
        //                    .overlay {
        //                        Capsule()
        //                            .stroke(.gray.opacity(0.25), lineWidth: 1)
        //                    }
        //                }
        //            }
        //        }
        //        .animation(.default, value: la.activityViewState?.activityState)
    }
}

#Preview {
    InfoTabLiveActivity(PreviewProp.serverAttributes)
        .darkSchemePreferred()
}
