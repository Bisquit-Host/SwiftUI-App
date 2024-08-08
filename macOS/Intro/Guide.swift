import ScrechKit
import Kingfisher
import PteroNet

struct Guide: View {
    @EnvironmentObject private var settings: SettingsStorage
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private let steps = [
        "Guide.Step1",
        "Guide.Step2",
        "Guide.Step3"
    ]
    
    private let images = [
        "step1",
        "step2"
    ]
    
    private var gradient: AngularGradient {
        AngularGradient(
            colors: colors,
            center: .init(x: 0.5, y: 1.0),
            angle: .degrees(180 * Double(step) / Double(steps.count - 1)))
    }
    
    private var colors: [Color] {
        switch colorScheme {
        case .dark:
            [.blue.opacity(0.5), .mint.opacity(0.5), .gray.opacity(0.5)]
            
        default:
            [.blue, .mint, .gray]
        }
    }
    
    @State private var step = 0
    @State private var apiKey = ""
    @ScaledMetric private var fontSize = 18
    
    var body: some View {
        VStack {
            Text("API-key Creation")
                .headline()
                .padding(.top)
            
            Text("Step \(step + 1)")
                .subheadline()
            
            Spacer()
            
            if step <= 1 {
                KFImage(getImageUrl(images[step]))
                    .fade(duration: 0.25)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding()
            }
            
            Text(LocalizedStringKey(steps[step]))
                .semibold()
                .serif()
                .fontSize(fontSize)
                .padding()
                .tightening(true)
                .lineLimit(1...5)
            
            if step == 2 {
                let url = URL(string: "https://mgr.bisquit.host")!
                
                Link(destination: url) {
                    Image(systemName: "link")
                        .title2(.semibold)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.blue, in: .capsule)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Dismiss")
                        .title2(.semibold)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.blue, in: .capsule)
                }
                .buttonStyle(.plain)
            }
            
            //            case 2:
            //                TextField("My API-key...", text: $apiKey)
            //                    .textFieldStyle(.roundedBorder)
            //                    .background(.gray)
            //                    .cornerRadius(16)
            //                    .padding()
            //                    .foregroundStyle(.black)
            //                    .multilineTextAlignment(.center)
            
            //                Button {
            //                    Keychain.save(key: "selectedApiKey", value: apiKey)
            //                    dismiss()
            //                } label: {
            //                    Text("Save")
            //                        .bold()
            //                        .padding()
            //                        .foregroundStyle(.white)
            //                        .background(.blue, in: .capsule)
            //                }
            //                .buttonStyle(.plain)
            
            Spacer()
            
            HStack {
                MenuButton("Previous", icon: "chevron.backward") {
                    withAnimation(.easeOut(duration: 0.6)) {
                        step -= 1
                    }
                }
                .keyboardShortcut(.leftArrow)
                .disabled(step - 1 < 0)
                
                Spacer()
                
                MenuButton("Next", icon: "chevron.forward") {
                    withAnimation(.easeOut(duration: 0.6)) {
                        step += 1
                    }
                }
                .keyboardShortcut(.rightArrow)
                .disabled(step + 1 >= steps.count)
            }
            .buttonStyle(CarouselButtonStyle())
            .padding(20)
        }
        .background(gradient)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    Guide()
        .environmentObject(SettingsStorage())
}
