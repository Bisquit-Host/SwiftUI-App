import ScrechKit

struct ANSIConverter {
    private static let ansiToSwiftUIColorMap = [
        30: Color(0xFF131a20), // Black
        31: Color(0xFFFE5370), // Red
        32: Color(0xFFC2E78C), // Green
        33: Color(0xFFFECA6B), // Yellow
        34: Color(0xFF396FE2), // Blue
        35: Color(0xFFBB80B3), // Magenta
        36: Color(0xFF88DCFE), // Cyan
        37: Color(0xFFD0D0D0), // White
        90: Color(0xFF333333), // Bright Black
        91: Color(0xFFFF5370), // Bright Red
        92: Color(0xFFC3E88D), // Bright Green
        93: Color(0xFFFFCB6B), // Bright Yellow
        94: Color(0xFF82AAFF), // Bright Blue
        95: Color(0xFFC792EA), // Bright Magenta
        96: Color(0xFF89DDFF), // Bright Cyan
        97: .white,            // Bright White
    ]
    
    public static func convertAnsiToAttributedString(_ input: String) -> AttributedString {
        let regexPattern = "\\x1b\\[[0-9;]*m"
        
        let regex = try! NSRegularExpression(pattern: regexPattern)
        let parts = input.split(separator: try! Regex(regexPattern))
        
        let matches = regex.matches(
            in: input,
            options: [],
            range: NSRange(
                location: 0,
                length: input.utf16.count
            )
        )
        
        var attributedString = AttributedString()
        var lastColor: Color = .primary
        var isBold = false
        var isUnderlined = false
        
        for (idx, part) in parts.enumerated() {
            var attributeContainer = AttributeContainer()
            attributeContainer.foregroundColor = lastColor
            
            if isBold {
                attributeContainer.font = attributeContainer.font?.bold()
            }
            
            if isUnderlined {
                attributeContainer.underlineStyle = .double
            }
            
            attributedString.append(
                AttributedString(part, attributes: attributeContainer)
            )
            
            if idx < matches.count {
                let match = matches[idx]
                
                let colorCode = (input as NSString)
                    .substring(with: match.range)
                    .dropFirst(2)
                    .dropLast()
                
                if colorCode.hasPrefix("38;2;") {
                    let rgb = colorCode
                        .dropFirst(5)
                        .split(separator: ";")
                        .map {
                            Double($0)! / 255
                        }
                    
                    lastColor = Color(
                        red: rgb[0],
                        green: rgb[1],
                        blue: rgb[2]
                    )
                } else {
                    let colorCodes = colorCode.split(separator: ";")
                    
                    for code in colorCodes {
                        switch code {
                        case "0":
                            isBold = false
                            isUnderlined = false
                            lastColor = .white
                            
                        case "21":
                            isUnderlined = true
                            
                        case "1":
                            isBold = true
                            
                        default:
                            if let codeInt = Int(code) {
                                lastColor = ANSIConverter.ansiToSwiftUIColorMap[codeInt] ?? lastColor
                            }
                        }
                    }
                }
            }
        }
        
        ANSIConverter.detectAndAddLinks(&attributedString)
        
        return attributedString
    }
    
    private static func detectAndAddLinks(_ attributedString: inout AttributedString) {
        guard let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        ) else {
            return
        }
        
        let mutableAttributedString = NSMutableAttributedString(
            attributedString: .init(attributedString)
        )
        
        let fullRange = NSRange(
            location: 0,
            length: mutableAttributedString.length
        )
#if os(macOS)
        let urlColor = NSColor.blue
#else
        let urlColor = UIColor.blue
#endif
        detector.enumerateMatches(
            in: mutableAttributedString.string,
            options: [],
            range: fullRange
        ) { match, _, _ in
            guard
                let match,
                let url = URL(string: (mutableAttributedString.string as NSString)
                    .substring(with: match.range))
            else {
                return
            }
            
            mutableAttributedString.addAttribute(.link, value: url, range: match.range)
            mutableAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: match.range)
            mutableAttributedString.addAttribute(.foregroundColor, value: urlColor, range: match.range)
        }
        
        attributedString = AttributedString(mutableAttributedString)
    }
}
