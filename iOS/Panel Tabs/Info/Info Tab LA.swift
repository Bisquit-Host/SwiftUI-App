import SwiftUI
import PteroNet

struct InfoTabLA: View {
    @State private var la = LiveActivity()
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    private var isActive: Bool {
        la.activityViewState?.activityState == .active
    }
    
    var body: some View {
        Button {
            if isActive {
                la.stopAllLiveActivities()
            } else {
                la.stopAllLiveActivities()
                
                Task {
                    await la.startLiveActivity(server)
                }
            }
        } label: {
            Image(systemName: "clock.badge")
        }
        .symbolVariant(isActive ? .fill : .none)
        .footnote(.bold)
        .frame(35)
        .background(.ultraThinMaterial, in: .circle)
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
        .title2(.semibold, design: .rounded)
        .foregroundStyle(.foreground)
        //        .animation(.default, value: la.activityViewState?.activityState)
    }
}

#Preview {
    InfoTabLA(sampleJSON(.serverListAttributes))
}
