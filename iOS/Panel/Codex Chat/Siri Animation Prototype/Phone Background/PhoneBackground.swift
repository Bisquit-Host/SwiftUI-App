import ScrechKit

struct PhoneBackground: View {
    let state: SiriState
    @Binding var origin: CGPoint
    @Binding var counter: Int
    var showsIdleSteps = false
    
    private var scrimOpacity: Double {
        switch state {
        case .none: 0
        case .thinking: 0.8
        }
    }
    
    @State private var step = 0
    
    @State private var steps = [
        "Reinstalling your server will stop it",
        "And then re-run the installation script that initially set it",
        "Some files may be deleted or modified during this process",
        "Please back up your data before continuing"
    ]
    
    var body: some View {
        ZStack {
            Image(.background)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(1.2) // avoid clipping
                .blur(radius: backgroundBlurRadius)
                .ignoresSafeArea()
            
            Rectangle()
                .fill(.black)
                .opacity(scrimOpacity)
                .scaleEffect(1.2) // avoid clipping
            
            VStack {
                if showsIdleSteps && state == .none {
                    Text(steps[step])
                        .title2(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 4)
                        .animation(.easeInOut(duration: 0.2), value: state)
                        .contentTransition(.opacity)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 80)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 64)
            .onPressingChanged { point in
                if let point {
                    origin = point
                    counter += 1
                }
            }
        }
    }

    private var backgroundBlurRadius: CGFloat {
        20
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var state: SiriState = .none
    @Previewable @State var origin = CGPoint(x: 0.5, y: 0.5)
    @Previewable @State var counter = 0
    
    PhoneBackground(state: state, origin: $origin, counter: $counter, showsIdleSteps: true)
}
