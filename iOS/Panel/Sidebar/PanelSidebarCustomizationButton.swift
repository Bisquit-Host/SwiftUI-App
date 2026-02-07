import ScrechKit

struct PanelSidebarCustomizationButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "slider.horizontal.3")
                    .headline()
                
                Text("Customization")
                    .semibold()
                
                Spacer(minLength: 0)
            }
            .foregroundStyle(.foreground)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .contentShape(.rect)
        }
        .secondary()
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}

#Preview {
    PanelSidebarCustomizationButton {
    }
    .padding()
}
