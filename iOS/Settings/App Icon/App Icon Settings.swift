import ScrechKit

struct AppIconSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    private let columns = [
        GridItem(.adaptive(minimum: 70, maximum: 70), spacing: 10)
    ]
    
    var body: some View {
        Section("Icon") {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Icon.allCases) {
                    AppIconCard($0, isSelected: store.currentIcon == $0)
                }
            }
            .padding(.vertical, 16)
        }
        .onChange(of: store.currentIcon) { _, newIcon in
            onIconChanged(newIcon)
        }
    }
    
    private func onIconChanged(_ icon: Icon) {
        guard UIApplication.shared.supportsAlternateIcons else {
            print("Device doesn't support alternate app icons")
            return
        }
        
        UIApplication.shared.setAlternateIconName(
            icon == .def ? nil : icon.rawValue
        )
    }
}

#Preview {
    AppIconSettings()
        .environmentObject(ValueStore())
}
