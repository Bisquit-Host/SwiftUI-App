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

//struct UnitTests {
//    @Test("Chmod")
//    func testChmod() {
//        print(chmod(execute: true))
//        print(chmod(write: true))
//        print(chmod(write: true, execute: true))
//        print(chmod(read: true))
//        print(chmod(read: true, execute: true))
//        print(chmod(read: true, write: true))
//        print(chmod(read: true, write: true, execute: true))
//    }
//    
//    func chmod( read: Bool = false, write: Bool = false, execute: Bool = false) -> UInt8 {
//        var permission: UInt8 = 0
//        
//        if read    { permission |= 4 }
//        if write   { permission |= 2 }
//        if execute { permission |= 1 }
//        
//        return permission
//    }
//    
//    @Test func `AttributedString`() {
//        let string = """
//Goida
//"""
//        print(ANSIConverter.convertAnsiToAttributedString(string))
//    }
//}
//
////final class LaunchTest: XCTestCase {
////    func testLaunchPerformance() {
////        measure(metrics: [XCTApplicationLaunchMetric()]) {
////            XCUIApplication().launch()
////        }
////    }
////}
