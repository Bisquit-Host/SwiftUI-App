import SwiftUI
import Highlightr
import Calagopus

struct HighlightrTextView: UIViewRepresentable {
    @Binding var text: String
    let selectedRange: NSRange
    let remoteCursors: [CalagopusFileCollaborationCursor]
    var isEditable = true
    let onSelectionChange: (NSRange) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.delegate = context.coordinator
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.isEditable = isEditable
        textView.backgroundColor = .systemBackground
        //        highlightr.setTheme(to: "paraiso-dark") // You can change the theme here
        context.coordinator.performProgrammaticUpdate {
            context.coordinator.updateText(
                text,
                in: textView,
                selection: selectedRange
            )
        }
        context.coordinator.renderRemoteCursorsIfNeeded(in: textView, force: true)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.parent = self
        uiView.isEditable = isEditable
        context.coordinator.performProgrammaticUpdate {
            if uiView.text != text {
                context.coordinator.updateText(
                    text,
                    in: uiView,
                    selection: selectedRange
                )
            } else if uiView.selectedRange != selectedRange {
                uiView.selectedRange = clamped(selectedRange, to: uiView.textStorage.length)
            }
        }

        context.coordinator.renderRemoteCursorsIfNeeded(in: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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
            guard !isApplyingProgrammaticUpdate else { return }

            parent.text = textView.text

            parent.onSelectionChange(textView.selectedRange)
            scheduleHighlighting(in: textView, debounce: true)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard !isApplyingProgrammaticUpdate else { return }
            parent.onSelectionChange(textView.selectedRange)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let textView = scrollView as? UITextView else { return }
            renderRemoteCursorsIfNeeded(in: textView, force: true)
        }

        func performProgrammaticUpdate(_ update: () -> Void) {
            isApplyingProgrammaticUpdate = true
            defer { isApplyingProgrammaticUpdate = false }
            update()
        }

        func updateText(
            _ text: String,
            in textView: UITextView,
            selection: NSRange
        ) {
            replaceTextPreservingAttributes(text, in: textView)
            textView.selectedRange = parent.clamped(
                selection,
                to: textView.textStorage.length
            )
            scheduleHighlighting(in: textView, debounce: false)
        }

        private func updateHighlighting(
            _ text: String,
            in textView: UITextView,
            selection: NSRange
        ) {
            if let highlighted = highlightr?.highlight(text) {
                //        if let highlighted = highlightr.highlight(text, as: language) {
                textView.attributedText = highlighted
                textView.selectedRange = parent.clamped(selection, to: highlighted.length)
            } else {
                textView.text = text
                textView.selectedRange = parent.clamped(
                    selection,
                    to: textView.textStorage.length
                )
            }
        }

        func renderRemoteCursorsIfNeeded(in textView: UITextView, force: Bool = false) {
            guard force || renderedRemoteCursors != parent.remoteCursors else { return }
            renderedRemoteCursors = parent.remoteCursors

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

        private func replaceTextPreservingAttributes(
            _ text: String,
            in textView: UITextView
        ) {
            let currentText = textView.text ?? ""
            guard currentText != text else { return }

            let current = currentText as NSString
            let updated = text as NSString
            let sharedLength = min(current.length, updated.length)
            var prefixLength = 0

            while
                prefixLength < sharedLength,
                current.character(at: prefixLength) == updated.character(at: prefixLength)
            {
                prefixLength += 1
            }

            let remainingCurrentLength = current.length - prefixLength
            let remainingUpdatedLength = updated.length - prefixLength
            let possibleSuffixLength = min(
                remainingCurrentLength,
                remainingUpdatedLength
            )
            var suffixLength = 0

            while
                suffixLength < possibleSuffixLength,
                current.character(at: current.length - suffixLength - 1)
                    == updated.character(at: updated.length - suffixLength - 1)
            {
                suffixLength += 1
            }

            let currentRange = NSRange(
                location: prefixLength,
                length: current.length - prefixLength - suffixLength
            )
            let updatedRange = NSRange(
                location: prefixLength,
                length: updated.length - prefixLength - suffixLength
            )

            textView.textStorage.replaceCharacters(
                in: currentRange,
                with: updated.substring(with: updatedRange)
            )
        }

        private func scheduleHighlighting(
            in textView: UITextView,
            debounce: Bool
        ) {
            if debounce {
                highlightingTask?.cancel()
            } else if highlightingTask != nil {
                return
            }

            highlightingTask = Task { [weak self, weak textView] in
                do {
                    try await Task.sleep(for: .milliseconds(150))
                } catch {
                    return
                }

                guard
                    let self,
                    let textView
                else {
                    return
                }

                let text = textView.text ?? ""
                let selection = textView.selectedRange
                performProgrammaticUpdate {
                    updateHighlighting(text, in: textView, selection: selection)
                }
                renderRemoteCursorsIfNeeded(in: textView, force: true)
                highlightingTask = nil
            }
        }

        private let highlightr = Highlightr()
        private var cursorViews: [Int: RemoteTextCursorView] = [:]
        private var selectionViews: [Int: [UIView]] = [:]
        private var renderedRemoteCursors: [CalagopusFileCollaborationCursor] = []
        private var highlightingTask: Task<Void, Never>?
        private var isApplyingProgrammaticUpdate = false
    }
}
