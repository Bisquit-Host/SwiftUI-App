import Testing
import Foundation
import XCTest

struct ANSITests {
    @Test func `Test ANSI speed`() throws {
        let bundle = Bundle(for: _BundleLocator.self)
        
        guard let url = bundle.url(forResource: "Console Output", withExtension: "txt") else {
            throw NSError(domain: "ANSITests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Output.txt not found"])
        }
        
        let contents = try String(contentsOf: url, encoding: .utf8)
        
        contents.enumerateLines { line, _ in
            let _ = ANSIConverter.convertAnsiToAttributedString(line)
        }
    }
}

private final class _BundleLocator: NSObject {}
