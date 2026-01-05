import Testing
import Foundation
import PteroNet
import XCTest

struct ANSITests {
    @Test func `Test ANSI speed`() throws {
        let contents = try String(contentsOf: fetchTxtFileURL("Console Output"), encoding: .utf8)
        
        contents.enumerateLines { line, _ in
            let _ = ANSIConverter.convertAnsiToAttributedString(line)
        }
    }
    
    @Test func `BigAssDecoder's benefits`() throws {
        let data = try Data(contentsOf: fetchTxtFileURL("Server List Output"))
        
        for _ in 0...1000 {
            let _ = try BigAssDecoder.decode(ServerListResponse.self, from: data)
        }
    }
    
    @Test func `Decode with JSONDecoder`() throws {
        let data = try Data(contentsOf: fetchTxtFileURL("Server List Output"))
        
        for _ in 0...1000 {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let _ = try decoder.decode(ServerListResponse.self, from: data)
        }
    }
    
    private func fetchTxtFileURL(_ filename: String) throws -> URL {
        let bundle = Bundle(for: _BundleLocator.self)
        
        guard let url = bundle.url(forResource: filename, withExtension: "txt") else {
            throw NSError(domain: "ANSITests", code: 1, userInfo: [NSLocalizedDescriptionKey: "\(filename).txt not found"])
        }
        
        return url
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
