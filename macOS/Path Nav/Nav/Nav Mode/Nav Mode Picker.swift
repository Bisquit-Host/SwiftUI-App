// Nav mode picker

import SwiftUI

struct NavModePicker: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var navMode: NavMode?
    
    init(_ navMode: Binding<NavMode?>) {
        _navMode = navMode
    }
    
    private var columns: [GridItem] {[
        GridItem(.adaptive(minimum: 250))
    ]}
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Choose your navigation experience")
                        .bold()
                        .largeTitle()
                        .lineLimit(2, reservesSpace: true)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                    
                    Text("You might need to restart the app")
                        .secondary()
                }
                .padding()
                
                Spacer()
                
                LazyVGrid(columns: columns) {
                    ForEach(NavMode.allCases) { exp in
                        NavModePickerItem($navMode, for: exp)
                    }
                }
                
                Spacer()
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
    @Previewable @State
    var navMode: NavMode? = .stack
    
    NavModePicker($navMode)
}
