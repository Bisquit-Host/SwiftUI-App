import ScrechKit

struct AppIconPicker: View {
    @EnvironmentObject private var store: ValueStore
    
    private let icons = [
        "default",
        "cool",
        "love",
        "streamer",
        "coin",
        "modern"
    ]
    
    @Namespace private var animation
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(icons, id: \.self) { icon in
                    AppIcon(icon, isSelected: store.currentIcon == icon)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                store.currentIcon = icon
                            }
                        }
                }
            }
            .padding(.horizontal, 5)
        }
        .onChange(of: store.currentIcon) { _, icon in
            if UIApplication.shared.supportsAlternateIcons {
                if icon == "default" {
                    UIApplication.shared.setAlternateIconName(nil)
                } else {
                    UIApplication.shared.setAlternateIconName(icon)
                }
            } else {
                print("Device doesn't support alternate app icons")
            }
        }
    }
}

#Preview {
    AppIconPicker()
        .environmentObject(ValueStore())
}
