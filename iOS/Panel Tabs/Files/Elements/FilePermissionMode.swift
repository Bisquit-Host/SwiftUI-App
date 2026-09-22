import Foundation

nonisolated struct FilePermissionMode: Equatable, Sendable {
    let value: UInt16

    init(value: UInt16) {
        self.value = value & 0o7777
    }

    init?(octal: String) {
        guard (3...4).contains(octal.count),
              octal.allSatisfy({ ("0"..."7").contains($0) }),
              let value = UInt16(octal, radix: 8) else { return nil }
        self.init(value: value)
    }

    init?(symbolic: String) {
        let symbols = Array(symbolic)
        guard symbols.count == 9 || symbols.count == 10 else { return nil }
        let permissions = Array(symbols.suffix(9))
        var value: UInt16 = 0

        for index in 0..<9 {
            let symbol = permissions[index]
            let allowed: String = switch index % 3 {
            case 0: "r-"
            case 1: "w-"
            default: index == 8 ? "xtT-" : "xsS-"
            }
            guard allowed.contains(symbol) else { return nil }

            if "rwxst".contains(symbol) {
                value |= 1 << (8 - index)
            }
            if symbol == "s" || symbol == "S" {
                value |= index == 2 ? 0o4000 : 0o2000
            } else if symbol == "t" || symbol == "T" {
                value |= 0o1000
            }
        }
        self.init(value: value)
    }

    var octal: String {
        let digits = String(value, radix: 8)
        return String(repeating: "0", count: max(0, 3 - digits.count)) + digits
    }

    func contains(_ mask: UInt16) -> Bool {
        value & mask != 0
    }
}
