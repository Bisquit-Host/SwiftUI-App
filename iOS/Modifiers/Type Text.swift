import SwiftUI

extension View {
    func typeText(
        _ text: Binding<String>,
        isFinished: Binding<Bool>,
        finalText: String,
        cursor: String = "|",
        isAnimated: Bool = true
    ) -> some View {
        self.modifier(
            TypeTextModifier(
                text: text,
                isFinished: isFinished,
                finalText: finalText,
                cursor: cursor,
                isAnimated: isAnimated
            )
        )
    }
}

private struct TypeTextModifier: ViewModifier {
    @Binding var text: String
    @Binding var isFinished: Bool
    var finalText: String
    var cursor: String
    var isAnimated: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !isAnimated {
                    text = finalText
                    isFinished = true
                }
            }
            .task {
                guard isAnimated else {
                    return
                }
                
                for _ in 1 ... 2 {
                    text = cursor
                    try? await Task.sleep(for: .milliseconds(500))
                    
                    text = ""
                    try? await Task.sleep(for: .milliseconds(200))
                }
                
                for index in finalText.indices {
                    text = String(finalText.prefix(through: index)) + cursor
                    
                    let milliseconds = (1 + UInt64.random(in: 0 ... 1)) * 100
                    
                    try? await Task.sleep(for: .milliseconds(milliseconds))
                }
                
                try? await Task.sleep(for: .milliseconds(400))
                
                text = finalText
                isFinished = true
            }
    }
}
