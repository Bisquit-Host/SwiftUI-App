import SwiftUI
import Highlightr

struct HighlightrTextView: UIViewRepresentable {
    @Binding var text: String
    //    var language = "json"
    var isEditable = true
    
    private let highlightr = Highlightr()!
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.delegate = context.coordinator
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
#if !os(tvOS)
        textView.isEditable = isEditable
        textView.backgroundColor = .systemBackground
#endif
        //        highlightr.setTheme(to: "paraiso-dark") // You can change the theme here
        updateHighlighting(textView)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            updateHighlighting(uiView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateHighlighting(_ textView: UITextView) {
        if let highlighted = highlightr.highlight(text) {
            //        if let highlighted = highlightr.highlight(text, as: language) {
            let selectedRange = textView.selectedRange
            
            textView.attributedText = highlighted
            textView.selectedRange = selectedRange
        } else {
            textView.text = text
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: HighlightrTextView
        
        init(_ parent: HighlightrTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.updateHighlighting(textView)
        }
    }
}
