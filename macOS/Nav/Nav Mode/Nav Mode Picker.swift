import SwiftUI

struct NavModePicker: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var navMode: NavMode?
    
    init(_ navMode: Binding<NavMode?>) {
        _navMode = navMode
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 250))
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 0) {
                    Text("Choose your navigation mode")
                        .bold()
                        .largeTitle()
                        .lineLimit(2, reservesSpace: true)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                    
                    Text("You might need to restart the app")
                        .secondary()
                }
                .padding()
                
                LazyVGrid(columns: columns) {
                    ForEach(NavMode.allCases) {
                        NavModePickerItem($navMode, for: $0)
                    }
                }
            }
            .scenePadding()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Dismiss") {
                    dismiss()
                }
            }
        }
        .frame(width: 600, height: 350)
        .interactiveDismissDisabled(navMode == nil)
    }
}

#Preview {
    @Previewable @State var navMode: NavMode? = .stack
    
    NavModePicker($navMode)
}
