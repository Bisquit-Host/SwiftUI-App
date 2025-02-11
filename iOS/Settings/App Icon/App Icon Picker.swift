import ScrechKit

struct AppIconPicker: View {
    @EnvironmentObject private var store: ValueStore
    
    @Namespace private var animation
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Icon.allCases) { icon in
                    AppIcon(icon, isSelected: store.currentIcon == icon)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                store.currentIcon = icon
                            }
                        }
                }
            }
            .padding(5)
        }
        .onChange(of: store.currentIcon) { _, icon in
            if UIApplication.shared.supportsAlternateIcons {
                UIApplication.shared.setAlternateIconName(
                    icon == .def ? nil : icon.rawValue
                )
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
