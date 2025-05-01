import ScrechKit

struct AppIconPicker: View {
    @EnvironmentObject private var store: ValueStore
    
    @Namespace private var animation
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Icon.allCases) { icon in
                    AppIconCard(icon, isSelected: store.currentIcon == icon)
                }
            }
            .padding(5)
        }
        .scrollClipDisabled()
        .onChange(of: store.currentIcon) { _, icon in
            guard UIApplication.shared.supportsAlternateIcons else {
                print("Device doesn't support alternate app icons")
                return
            }
            
            UIApplication.shared.setAlternateIconName(
                icon == .def ? nil : icon.rawValue
            )
        }
    }
}

#Preview {
    AppIconPicker()
        .environmentObject(ValueStore())
}
