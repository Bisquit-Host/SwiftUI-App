import SwiftUI

struct GuideControls: View {
    @Binding private var step: Int
    private let stepCount: Int
    
    init(_ step: Binding<Int>, stepCount: Int) {
        _step = step
        self.stepCount = stepCount
    }
    
    var body: some View {
        HStack {
            Button("Previous", systemImage: "chevron.backward") {
                withAnimation(.easeOut(duration: 0.6)) {
                    step -= 1
                }
            }
            .keyboardShortcut(.leftArrow)
            .disabled(step - 1 < 0)
            
            Spacer()
            
            Button("Next", systemImage: "chevron.forward") {
                withAnimation(.easeOut(duration: 0.6)) {
                    step += 1
                }
            }
            .keyboardShortcut(.rightArrow)
            .disabled(step + 1 >= stepCount)
        }
        .buttonStyle(CarouselButtonStyle())
        .padding(20)
    }
}
