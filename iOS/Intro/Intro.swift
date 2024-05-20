import ScrechKit
import Kingfisher

struct Intro: View {
    @State private var currentIndex = 0
    @State private var showHomeview = false
    @State private var showWalkThroughScreens = false
    @State private var color = Color(0xe3a65e).opacity(0.8)
    
    private let intros = [
        IntroItem("Best Performance", text: "Intro.Text1", imageName: "streamer"),
        IntroItem("Innovation", text: "Intro.Text1", imageName: "badge"),
        IntroItem("Support", text: "Intro.Text1", imageName: "heart")
    ]
    
    @State private var trigger = true
    
    var body: some View {
        ZStack {
            if showHomeview {
                StartPage()
                    .transition(.move(edge: .trailing))
            } else {
                ZStack {
                    color.ignoresSafeArea()
                    IntroScreen()
                    WalkThroughScreens()
                    NavBar()
                }
                .foregroundStyle(.white)
                .animation(
                    .interactiveSpring(
                        response: 1.1,
                        dampingFraction: 0.85,
                        blendDuration: 0.85
                    ),
                    value: showWalkThroughScreens
                )
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.5),
                   value: showHomeview)
    }
    
    @ViewBuilder
    func IntroScreen() -> some View {
        GeometryReader {
            let size = $0.size
            
            VStack(spacing: 10) {
                Image(.logo)
                    .resizable()
                    .frame(width: size.width / 1.5, height: size.width / 1.5)
                    .frame(maxWidth: 500, maxHeight: 500)
                
                Spacer().frame(height: 20)
                
                Text("Bisquit.Host")
                    .largeTitle(.bold, design: .rounded)
                
                Text("Intro.Text0")
                    .title(.bold, design: .rounded)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer().frame(height: 40)
                
                HStack {
                    Button {
                        withAnimation(.easeOut(duration: 1)) {
                            showWalkThroughScreens.toggle()
                            color = Color(0xe3a65e)
                        }
                    } label: {
                        Text("Lift-off 🚀")
                            .title3(.semibold)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 16)
                            .foregroundStyle(.white)
                            .background(.blue.gradient, in: .capsule)
                            .conditionalEffect(
                                .repeat(
                                    .glow(color: .blue),
                                    every: 2
                                ),
                                condition: trigger
                            )
                    }
                    
                    Spacer().frame(width: 32)
                    
                    LanguageButton()
                }
            }
            .padding(.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: showWalkThroughScreens ? -size.height * 1.1 : 0)
        }
    }
    
    @ViewBuilder
    func WalkThroughScreens() -> some View {
        let isLast = currentIndex == intros.count
        
        GeometryReader {
            let size = $0.size
            
            ZStack {
                ForEach(intros.indices, id: \.self) { index in
                    ScreenView(size: size, index: index)
                }
                
                WelcomeView(size: size, index: intros.count)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                ZStack {
                    Image(systemName: "chevron.right")
                        .title(.semibold)
                        .scaleEffect(isLast ? 0.001 : 1)
                        .opacity(isLast ? 0 : 1)
                    
                    HStack {
                        Text("Sign in")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "arrow.right")
                            .title3(.semibold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 15)
                    .scaleEffect(isLast ? 1 : 0.001)
                    .frame(height: isLast ? nil : 0)
                    .opacity(isLast ? 1 : 0)
                }
                .frame(width: isLast ? size.width / 1.5 : 55, height: isLast ? 50 : 55)
                .foregroundStyle(.white)
                .background {
                    RoundedRectangle(cornerRadius: isLast ? 10 : 30, style: isLast ? .continuous : .circular)
                        .fill(.blue.gradient)
                }
                .onTapGesture {
                    if currentIndex == intros.count {
                        withAnimation {
                            showHomeview = true
                        }
                    } else {
                        currentIndex += 1
                    }
                }
                .offset(y: isLast ? -40 : -90)
                .animation(
                    .interactiveSpring(
                        response: 0.9,
                        dampingFraction: 0.8,
                        blendDuration: 0.5
                    ),
                    value: isLast
                )
            }
            .offset(y: showWalkThroughScreens ? 0 : size.height)
        }
    }
    
    @ViewBuilder
    func ScreenView(size: CGSize, index: Int) -> some View {
        let intro = intros[index]
        
        VStack(spacing: 10) {
            KFImage(getImageUrl(intro.imageName))
                .resizable()
                .fade(duration: 0.25)
                .scaledToFit()
                .padding(.horizontal)
                .frame(maxHeight: 260)
                .animation(
                    .interactiveSpring(
                        response: 0.9,
                        dampingFraction: 0.8,
                        blendDuration: 0.5
                    ).delay(0.1),
                    value: currentIndex
                )
            
            Text(intro.title)
                .title(.semibold)
                .minimumScaleFactor(0.1)
                .scaledToFit()
                .padding(.horizontal)
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(0.2), value: currentIndex)
            
            Text(intro.text)
                .title2(.medium, design: .rounded)
                .multilineTextAlignment(.leading)
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(0.3), value: currentIndex)
                .padding(20)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 40)
        }
        .offset(x: -size.width * CGFloat(currentIndex - index), y: -30)
    }
    
    @ViewBuilder
    func WelcomeView(size: CGSize, index: Int) -> some View {
        VStack(spacing: 10) {
            Text("We are Bisquit.Host")
                .largeTitle(.bold, design: .rounded)
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(0.1), value: currentIndex)
            
            Text("Are you ready?")
                .title(design: .serif)
                .multilineTextAlignment(.center)
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(0.2), value: currentIndex)
        }
        .offset(x: -size.width * CGFloat(currentIndex - index), y: -30)
    }
    
    @ViewBuilder
    func NavBar() -> some View {
        let isLast = currentIndex == intros.count
        
        HStack {
            Button {
                currentIndex = intros.count
            } label: {
                Label("Skip", systemImage: "arrowshape.bounce.forward.fill")
                    .footnote()
                    .foregroundStyle(.white)
                    .opacity(isLast ? 0 : 1)
                    .animation(.easeInOut, value: isLast)
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
        .frame(maxHeight: .infinity, alignment: .top)
        .offset(y: showWalkThroughScreens ? 0 : -120)
    }
}

#Preview {
    Intro()
}
