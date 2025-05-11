import Cocoa
import Quartz

class PreviewViewController: NSViewController, QLPreviewingController {
    private var previewLabel: NSTextField?
    
    override var nibName: NSNib.Name? {
        NSNib.Name("PreviewViewController")
    }
    
    override func loadView() {
        super.loadView()
        // Initial label
        addLabel("Hello, Quick Look!")
    }
    
    func addLabel(_ text: String) {
        // Remove previous label if exists
        previewLabel?.removeFromSuperview()
        
        // Create and configure new label
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        previewLabel = label
    }
    
    // Read file contents
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
