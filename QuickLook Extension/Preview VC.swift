import Cocoa
import Quartz

class PreviewViewController: NSViewController, QLPreviewingController {
    private var scrollView: NSScrollView?
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLabel("Hello, Quick Look!")
    }
    
    func addLabel(_ text: String) {
        scrollView?.removeFromSuperview()
        
        // Create the text view with a non-zero frame
        let textView = NSTextView(frame: .zero)
        textView.string = text
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = .systemFont(ofSize: 14)
        textView.drawsBackground = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView = textView
        scroll.hasVerticalScroller = true
        scroll.borderType = .bezelBorder
        
        view.addSubview(scroll)
        scrollView = scroll
        
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    func preparePreviewOfFile(at url: URL) async throws {
        let text: String
        
        do {
            text = try String(contentsOf: url, encoding: .utf8)
        } catch {
            text = "Could not read file: \(error.localizedDescription)"
        }
        
        addLabel(text)
    }
}
