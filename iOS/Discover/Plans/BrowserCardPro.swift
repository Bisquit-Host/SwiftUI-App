import SwiftUI
import ScrechKit

func customRound(_ value: Double) -> String {
    let roundedValue = round(value)
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = (roundedValue == value) ? 0 : 1
    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

struct BrowserCardSpec: View {
    private let icon: String
    private let spec: String
    
    init(_ icon: String, spec: String) {
        self.icon = icon
        self.spec = spec
    }
    
    var body: some View {
        Label(spec, systemImage: icon)
            .semibold()
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 5)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .opacity(0.95)
            }
    }
}

struct Browser_Card: View {
    @Environment(\.colorScheme) private var scheme
    
    private let plan: Plan
    
    init(_ plan: Plan) {
        self.plan = plan
    }
    
    private let url = "https://my.bisquit.host/store/minecraft/"

    var body: some View {
        let ram = plan.ram * pow(10, 9)
        let disk = plan.disk * pow(10, 9)
        
        ZStack {
            Image("test")
                .resizable()
                .brightness(scheme == .dark ? -0.1 : 0)
            
            Image("test")
                .resizable()
                .mask(alignment: .topLeading) {
                    Text(NSLocalizedString("Plan." + plan.name, comment: ""))
                        .title()
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background()
                        .cornerRadius(16)
                }
                .blur(radius: 4)
                .brightness(scheme == .dark ? -0.1 : 0)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("Plan." + plan.name, comment: ""))
                        .title(.semibold)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 5)
                    
                    Spacer()
                    
                    HStack {
                        BrowserCardSpec("cpu", spec: "\(customRound(plan.cpu))x")
                        BrowserCardSpec("memorychip", spec: formatBytes(ram, countStyle: .decimal))
                        BrowserCardSpec("internaldrive", spec: formatBytes(disk, countStyle: .decimal))
                        
                        Spacer()
                        
                        HStack(spacing: 0) {
                            Text("300")
                                .subheadline()
                            
                            Image(systemName: "rublesign")
                                .caption2()
                        }
                        .bold()
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .foregroundColor(.white)
                        .background(Capsule(.blue))
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .cornerRadius(20)
        .frame(maxWidth: 500)
        .frame(height: 160)
        .padding(5)
    }
}
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}


struct BrowserCardPro_Previews: PreviewProvider {
    static var previews: some View {
        Browser_Card(Plan(name: "", url: "bee", cpu: 0, ram: 0, disk: 0, price_euro: 0, price_rub: 0, price_usd: 0))
            .darkSchemePreferred()
        
        Browser_Card(Plan(name: "", url: "bee", cpu: 0, ram: 0, disk: 0, price_euro: 0, price_rub: 0, price_usd: 0))
    }
}
