import ScrechKit

struct ANSIConverter {
    // MARK: - Cache
    private static let ansiRegex = try! NSRegularExpression(pattern: "\\x1b\\[([0-9;]*)m")
    private static let linkDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    
    private static let standardColors = [
        30: Color(0x131a20), 31: Color(0xFE5370), 32: Color(0xC2E78C),
        33: Color(0xFECA6B), 34: Color(0x396FE2), 35: Color(0xBB80B3),
        36: Color(0x88DCFE), 37: Color(0xD0D0D0),
        90: Color(0x333333), 91: Color(0xFF5370), 92: Color(0xC3E88D),
        93: Color(0xFFCB6B), 94: Color(0x82AAFF), 95: Color(0xC792EA),
        96: Color(0x89DDFF), 97: .white
    ]
    
    public static func convertAnsiToAttributedString(_ input: String) -> AttributedString {
#if os(macOS)
        let font = NSFont.systemFont(ofSize: 12, weight: .regular)
#else
        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
#endif
        var currentContainer = AttributeContainer([.font: font])
        
        // Set default font to ensure monospaced alignment usually desired with ANSI
        currentContainer.foregroundColor = .primary
        
        // Ensure emphasis attributes can be mutated (bold fix)
        currentContainer.inlinePresentationIntent = []
        
        let nsString = input as NSString
        let length = nsString.length
        var searchRange = NSRange(location: 0, length: length)
        
        var attributedString = AttributedString()
        
        while searchRange.location < length {
            // Find the next ANSI escape code
            let match = ansiRegex.firstMatch(in: input, options: [], range: searchRange)
            
            // 1. Append text *before* the code using current attributes
            let endOfText = match?.range.location ?? length
            let textRange = NSRange(location: searchRange.location, length: endOfText - searchRange.location)
            
            if textRange.length > 0 {
                let textChunk = nsString.substring(with: textRange)
                attributedString.append(AttributedString(textChunk, attributes: currentContainer))
            }
            
            guard let match else {
                break
            }
            
            // 2. Parse the code and update state
            let codeContentRange = match.range(at: 1) // The part inside [ ... m
            
            if codeContentRange.length > 0 {
                let codeString = nsString.substring(with: codeContentRange)
                updateAttributes(&currentContainer, codeString: codeString)
            } else {
                // Empty code "\x1b[m" is treated as reset
                updateAttributes(&currentContainer, codeString: "0")
            }
            
            // 3. Advance search past the match
            searchRange.location = match.range.upperBound
            searchRange.length = length - searchRange.location
        }
        
        // 4. Detect Links (Post-processing)
        detectAndStyleLinks(&attributedString)
        
        return attributedString
    }
    
    // MARK: - Attribute Logic
    private static func updateAttributes(_ attributes: inout AttributeContainer, codeString: String) {
        let codes = codeString.split(separator: ";").compactMap {
            Int($0)
        }
        
        var iterator = codes.makeIterator()
        
        while let code = iterator.next() {
            switch code {
            case 0: // Reset
                attributes.foregroundColor = .primary
                attributes.backgroundColor = nil
                attributes.inlinePresentationIntent = [] // Resets bold/italic
                attributes.underlineStyle = nil
                
            case 1: // Bold
                // SwiftUI AttributeContainer logic for Bold isn't direct property, usually intent or font modification
                attributes.inlinePresentationIntent?.insert(.stronglyEmphasized)
                
            case 3: // Italic
                attributes.inlinePresentationIntent?.insert(.emphasized)
                
            case 4: // Underline
                attributes.underlineStyle = .single
                
            case 21: // Double Underline (Mapping to single for SwiftUI simplicity or double if supported)
#if os(iOS)
                attributes.underlineStyle = .single // iOS doesn't strictly render double underline easily in Text
#else
                attributes.underlineStyle = .double
#endif
            case 22: // No Bold/Faint
                attributes.inlinePresentationIntent?.remove(.stronglyEmphasized)
                
            case 24: // No Underline
                attributes.underlineStyle = nil
                
            case 30...37, 90...97: // Standard Foreground
                attributes.foregroundColor = standardColors[code]
                
            case 39: // Default Foreground
                attributes.foregroundColor = .primary
                
            case 40...47, 100...107: // Standard Background
                // Mapping BG codes to FG colors for simplicity, or define specific BG palette
                // 40 is black (30), 41 is red (31)... offset is 10
                if let color = standardColors[code - 10] {
                    attributes.backgroundColor = color
                }
                
            case 49: // Default Background
                attributes.backgroundColor = nil
                
            case 38: // Extended Foreground (38;5;n or 38;2;r;g;b)
                if let color = parseExtendedColor(&iterator) {
                    attributes.foregroundColor = color
                }
                
            case 48: // Extended Background
                if let color = parseExtendedColor(&iterator) {
                    attributes.backgroundColor = color
                }
                
            default:
                break
            }
        }
    }
    
    private static func parseExtendedColor(_ iterator: inout IndexingIterator<[Int]>) -> Color? {
        guard let type = iterator.next() else {
            return nil
        }
        
        if type == 5 { // 256 Colors: 38;5;n
            guard let index = iterator.next() else {
                return nil
            }
            
            return getXtermColor(index)
            
        } else if type == 2 { // TrueColor: 38;2;r;g;b
            guard
                let r = iterator.next(),
                let g = iterator.next(),
                let b = iterator.next()
            else {
                return nil
            }
            
            return Color(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
        }
        
        return nil
    }
    
    // MARK: - Link Detection
    
    private static func detectAndStyleLinks(_ attributedString: inout AttributedString) {
        guard let linkDetector else { return }
        
        // We convert to NSAttributedString temporarily for detection because NSDataDetector requires NSString ranges
        let nsAttrString = NSAttributedString(attributedString)
        let plainText = nsAttrString.string
        let range = NSRange(location: 0, length: plainText.utf16.count)
        
        linkDetector.enumerateMatches(in: plainText, options: [], range: range) { match, _, _ in
            guard let match, let url = match.url else {
                return
            }
            
            // Convert NSRange back to AttributedString.Index
            if let swiftRange = Range(match.range, in: attributedString) {
                attributedString[swiftRange].link = url
                attributedString[swiftRange].foregroundColor = .blue
                attributedString[swiftRange].underlineStyle = .single
            }
        }
    }
    
    // MARK: - Color Helpers
    private static func getXtermColor(_ index: Int) -> Color {
        // 0-15: Standard Colors
        if let standard = standardColors[index] ?? standardColors[index + (index < 8 ? 30 : 82)] {
            return standard
        }
        
        // 16-231: 6x6x6 Cube
        if index >= 16 && index <= 231 {
            let baseIndex = index - 16
            let r = (baseIndex / 36) % 6
            let g = (baseIndex / 6) % 6
            let b = baseIndex % 6
            
            return Color(
                red: Double(r) * 51 / 255, // 0, 51, 102, 153, 204, 255
                green: Double(g) * 51 / 255,
                blue: Double(b) * 51 / 255
            )
        }
        
        // 232-255: Grayscale
        if index >= 232 && index <= 255 {
            let gray = Double(index - 232) * 10 + 8
            return Color(red: gray / 255, green: gray / 255, blue: gray / 255)
        }
        
        return .primary
    }
}
