import SwiftUI

struct NavModePickerItem: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var selection: NavMode?
    
    private var navMode: NavMode
    
    init(_ selection: Binding<NavMode?>, for navMode: NavMode) {
        _selection = selection
        self.navMode = navMode
    }
    
    var body: some View {
        Button {
            selection = navMode
            dismiss()
        } label: {
            Label(selection: $selection, navMode: navMode)
        }
        .buttonStyle(.plain)
    }
}

private struct Label: View {
    @Binding var selection: NavMode?
    var navMode: NavMode
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: navMode.imageName)
                .title()
                .foregroundStyle(shapeStyle(Color.accentColor))
            
            VStack(alignment: .leading) {
                Text(navMode.localizedName)
                    .bold()
                    .foregroundStyle(shapeStyle(Color.primary))
                
                Text(navMode.localizedDescription)
                    .callout()
                    .lineLimit(3, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(shapeStyle(Color.secondary))
            }
        }
        .shadow(radius: selection == navMode ? 4 : 0)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(selection == navMode ?
                      AnyShapeStyle(Color.accentColor) :
                        AnyShapeStyle(BackgroundStyle()))
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isHovering ? Color.accentColor : .clear)
        }
        .scaleEffect(isHovering ? 1.02 : 1)
        .onHover { isHovering in
            withAnimation {
                self.isHovering = isHovering
            }
        }
    }
    
    private func shapeStyle<S: ShapeStyle>(_ style: S) -> some ShapeStyle {
        if selection == navMode {
            AnyShapeStyle(.background)
        } else {
            AnyShapeStyle(style)
        }
    }
}

#Preview {
    @Previewable @State
    var selection: NavMode?
    
    ForEach(NavMode.allCases) {
        NavModePickerItem(
            $selection,
            for: $0
        )
    }
}
