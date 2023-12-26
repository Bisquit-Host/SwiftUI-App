import XCTest

final class UnitTests: XCTestCase {
    func testChmod() {
        print(chmod(execute: true))
        print(chmod(write: true))
        print(chmod(write: true, execute: true))
        print(chmod(read: true))
        print(chmod(read: true, execute: true))
        print(chmod(read: true, write: true))
        print(chmod(read: true, write: true, execute: true))
    }
    
    func chmod(read: Bool = false, write: Bool = false, execute: Bool = false) -> UInt8 {
        var permission: UInt8 = 0
        
        if read { permission |= 4 }
        if write { permission |= 2 }
        if execute { permission |= 1 }
        
        return permission
    }
    
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
