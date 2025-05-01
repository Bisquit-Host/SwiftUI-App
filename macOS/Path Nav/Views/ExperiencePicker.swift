// A navigation experience picker used to select the navigation architecture for the app

import SwiftUI

struct ExperiencePicker: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var experience: Experience?
    
    @State private var selection: Experience?
    
    init(_ experience: Binding<Experience?>) {
        _experience = experience
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Choose your navigation experience")
                    .largeTitle(.bold)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .padding()
                
                Spacer()
                
                LazyVGrid(columns: columns) {
                    ForEach(Experience.allCases) { experience in
                        ExperiencePickerItem(
                            selection: $selection,
                            experience: experience)
                    }
                }
                
                Spacer()
            }
            .scenePadding()
#if os(iOS)
            .safeAreaInset(edge: .bottom) {
                ContinueButton {
                    continueAction()
                }
                .disabled(selection == nil)
                .scenePadding()
            }
#endif
        }
#if os(macOS)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                ContinueButton {
                    continueAction()
                }
                .disabled(selection == nil)
            }
        }
        .frame(width: 600, height: 350)
#endif
        .interactiveDismissDisabled(selection == nil)
    }
    
    private var columns: [GridItem] {[
        GridItem(.adaptive(minimum: 250))
    ]}
    
    private func continueAction() {
        experience = selection
        dismiss()
    }
}

#Preview() {
    @Previewable @State var selectedExperience: Experience? = .stack
    
    ExperiencePicker($selectedExperience)
}
