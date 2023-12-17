import ScrechKit

struct AppIconPicker: View {
    @EnvironmentObject private var settings: SettingsStorage
    
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
                    AppIcon(icon, isSelected: settings.currentIcon == icon)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                settings.currentIcon = icon
                            }
                        }
                }
            }
            .padding(.horizontal, 5)
        }
        .onChange(of: settings.currentIcon) { _, icon in
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
        .environmentObject(SettingsStorage())
}
