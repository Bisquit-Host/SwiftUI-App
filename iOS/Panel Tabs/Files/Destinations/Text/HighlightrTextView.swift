import SwiftUI
import Highlightr
import Calagopus

struct HighlightrTextView: UIViewRepresentable {
    @Binding var text: String
    let selectedRange: NSRange
    let remoteCursors: [CalagopusFileCollaborationCursor]
    var isEditable = true
    let onSelectionChange: (NSRange) -> Void

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
        updateHighlighting(textView, selection: selectedRange)
        context.coordinator.renderRemoteCursors(in: textView)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.parent = self
#if !os(tvOS)
        uiView.isEditable = isEditable
#endif
        if uiView.text != text {
            updateHighlighting(uiView, selection: selectedRange)
        } else if uiView.selectedRange != selectedRange {
            uiView.selectedRange = clamped(selectedRange, to: uiView.textStorage.length)
        }

        context.coordinator.renderRemoteCursors(in: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func updateHighlighting(_ textView: UITextView, selection: NSRange) {
        if let highlighted = highlightr.highlight(text) {
            //        if let highlighted = highlightr.highlight(text, as: language) {
            textView.attributedText = highlighted
            textView.selectedRange = clamped(selection, to: highlighted.length)
        } else {
            textView.text = text
            textView.selectedRange = clamped(selection, to: textView.textStorage.length)
        }
    }

    private func clamped(_ range: NSRange, to length: Int) -> NSRange {
        let location = min(range.location, length)
        return NSRange(location: location, length: min(range.length, length - location))
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: HighlightrTextView

        init(_ parent: HighlightrTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            let selectedRange = textView.selectedRange
            parent.text = textView.text
            parent.updateHighlighting(textView, selection: selectedRange)
            parent.onSelectionChange(textView.selectedRange)
            renderRemoteCursors(in: textView)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.onSelectionChange(textView.selectedRange)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let textView = scrollView as? UITextView else { return }
            renderRemoteCursors(in: textView)
        }

        func renderRemoteCursors(in textView: UITextView) {
            selectionViews.values
                .flatMap(\.self)
                .forEach { $0.removeFromSuperview() }
            selectionViews = [:]

            let activeIDs = Set(parent.remoteCursors.map(\.id))

            for cursor in parent.remoteCursors {
                let color = RemoteTextCursorView.color(from: cursor.color)
                let start = min(cursor.anchor, cursor.head, textView.textStorage.length)
                let end = min(max(cursor.anchor, cursor.head), textView.textStorage.length)

                selectionViews[cursor.id] = remoteSelectionViews(
                    in: textView,
                    start: start,
                    end: end,
                    color: color
                )

                guard
                    let position = textView.position(
                        from: textView.beginningOfDocument,
                        offset: min(cursor.head, textView.textStorage.length)
                    )
                else {
                    continue
                }

                let cursorView = cursorViews[cursor.id] ?? RemoteTextCursorView()
                cursorViews[cursor.id] = cursorView

                if cursorView.superview == nil {
                    textView.addSubview(cursorView)
                }

                cursorView.configure(
                    name: cursor.name,
                    color: color,
                    caretRect: textView.caretRect(for: position),
                    visibleBounds: textView.bounds
                )
                textView.bringSubviewToFront(cursorView)
            }

            let staleIDs = cursorViews.keys.filter { !activeIDs.contains($0) }

            for id in staleIDs {
                cursorViews.removeValue(forKey: id)?.removeFromSuperview()
            }
        }

        private func remoteSelectionViews(
            in textView: UITextView,
            start: Int,
            end: Int,
            color: UIColor
        ) -> [UIView] {
            guard
                end > start,
                let startPosition = textView.position(from: textView.beginningOfDocument, offset: start),
                let endPosition = textView.position(from: textView.beginningOfDocument, offset: end),
                let range = textView.textRange(from: startPosition, to: endPosition)
            else {
                return []
            }

            return textView.selectionRects(for: range).compactMap {
                guard !$0.rect.isEmpty else { return nil }

                let view = UIView(frame: $0.rect)
                view.backgroundColor = color.withAlphaComponent(0.27)
                view.isUserInteractionEnabled = false
                view.isAccessibilityElement = false
                textView.addSubview(view)
                return view
            }
        }

        private var cursorViews: [Int: RemoteTextCursorView] = [:]
        private var selectionViews: [Int: [UIView]] = [:]
    }
}
