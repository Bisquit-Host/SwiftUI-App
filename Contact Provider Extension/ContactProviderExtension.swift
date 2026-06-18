#if canImport(ContactProvider)
import ExtensionFoundation
import ContactProvider

@main
class CPExtension: ContactProviderExtension {
    private let rootContainerEnumerator: ExtensionRootContainerEnumerator
    
    required init() {
        // Initialize your extension here
        rootContainerEnumerator = ExtensionRootContainerEnumerator()
    }
    
    func configure(for domain: ContactProviderDomain) {
        // Configure your extension here
        rootContainerEnumerator.configure(for: domain)
    }
    
    func enumerator(for collection: ContactItem.Identifier) -> ContactItemEnumerator {
        rootContainerEnumerator
    }
    
    func invalidate() async {
        // TODO: Stop any enumeration and cleanup as the extension will be terminated
    }
}
#endif
