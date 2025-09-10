import Quartz

class PreviewViewController: NSViewController, QLPreviewingController {
    private var scrollView: NSScrollView?
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addLabel(_ text: String) {
        scrollView?.removeFromSuperview()
        
        let textView = NSTextView(frame: .zero)
        let scroll = NSScrollView()
        
        textView.string = text
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = .systemFont(ofSize: 14)
        textView.drawsBackground = false // clear background
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        
        textView.textContainer?.containerSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView = textView
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false // clear background
        
        view.addSubview(scroll)
        scrollView = scroll
        
        let padding = 5.0
        
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
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
